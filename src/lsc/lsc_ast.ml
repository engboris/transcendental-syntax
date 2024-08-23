open Base
open Pretty

type polarity = Pos | Neg | Null

module StellarSig = struct
  type idvar = string * int option
  type idfunc = polarity * string
  let equal_idvar (s, i) (s', i') =
    match i, i' with
    | None, None -> equal_string s s'
    | Some j, Some j' -> equal_string s s' && equal_int j j'
    | _ -> false

  let equal_idfunc (p, f) (p', f') =
    match p, p' with
    | Pos, Pos | Neg, Neg | Null, Null -> equal_string f f'
    | _ -> false

  let compatible f g =
    match f, g with
    | (Pos, f), (Neg, g)
    | (Neg, f), (Pos, g) -> equal_string f g
    | (Null, f), (Null, g) -> equal_string f g
    | _ -> false

  let apply_effect f args =
    match f, args with
    | (_, "print"), (Null, s)::_ ->
        let size = String.length s in
        if equal_char (String.get s 0) '"' &&
           equal_char (String.get s (size-1)) '"' then
          s
          |> String.lstrip ~drop:(equal_char '"')
          |> String.rstrip ~drop:(equal_char '"')
          |> Stdlib.print_string
    | _ -> ()
end

module StellarRays = Unification.Make(StellarSig)

open StellarRays

(* ---------------------------------------
   Stars and Constellations
   --------------------------------------- *)

let counter_placeholder = ref 0
let fresh_placeholder () =
  let r = !counter_placeholder in
  (counter_placeholder := !counter_placeholder + 1);
  (Int.to_string r)

type ray = term
type star = ray list
type constellation = star list

let equal_ray = equal_term

let to_var x = Var (x, None)
let to_func (pf, ts) = Func (pf, ts)

let pos f = (Pos, f)
let neg f = (Neg, f)
let null f = (Null, f)

let gfunc c ts = Func (c, ts)
let pfunc f ts = gfunc (pos f) ts
let nfunc f ts = gfunc (neg f) ts
let func f ts = gfunc (null f) ts
let var x = Var x
let pconst f = pfunc f []
let nconst f = nfunc f []
let const f = func f []
let dot t u = nfunc ":" [t; u]

let is_polarised r : bool =
  let aux = function
  | (Pos, _) | (Neg, _) -> true
  | (Null, _) -> false
  in exists_func aux r

let replace_indices (i : int) : ray -> ray =
  map Fn.id (fun (x, _) -> Var (x, Some i))

(* ---------------------------------------
   Pretty Printer
   --------------------------------------- *)

let string_of_polarity = function
  | Pos -> "+"
  | Neg -> "-"
  | Null -> ""

let string_of_polsym (p, f) = (string_of_polarity p) ^ f

let string_of_var (x, i) =
  match i with
  | None -> x
  | Some i' -> x ^ (Int.to_string i')

let rec string_of_ray = function
  | Var xi -> string_of_var xi
  | Func (pf, []) -> string_of_polsym pf
  | Func ((Null, ":"), [Func ((Null, ":"), [r1; r2]); r3]) ->
    "(" ^ (string_of_ray r1) ^ ":"  ^ (string_of_ray r2) ^ "):" ^
    (string_of_ray r3)
  | Func ((Null, ":"), [r1; r2]) ->
    (string_of_ray r1) ^ ":"  ^ (string_of_ray r2)
  | Func (pf, ts) -> string_of_polsym pf ^
    surround "(" ")" @@
    string_of_list string_of_ray " " ts

let string_of_subst sub =
  List.fold sub ~init:"" ~f:(fun _ (x, r) ->
    (string_of_var x) ^ "->" ^ (string_of_ray r))
  |> surround "{" "}"

let string_of_star s =
  if List.is_empty s then "[]"
  else string_of_list string_of_ray " " s

let string_of_constellation cs =
  if List.is_empty cs then "{}"
  else (string_of_list string_of_star ";\n" cs) ^ ";"

(* ---------------------------------------
   Interactive execution
   --------------------------------------- *)

type marked_star = Marked of star | Unmarked of star
type marked_constellation = marked_star list

let map_mstar ~f : marked_star -> marked_star = function
  | Marked s -> Marked (List.map ~f:f s)
  | Unmarked s -> Unmarked (List.map ~f:f s)

let unmark = function s -> Unmarked s

let remove_mark = function
  | Marked s -> s
  | Unmarked s -> s

let unmark_all = List.map ~f:(fun s -> Unmarked s)
let remove_mark_all = List.map ~f:remove_mark

let extract_intspace (mcs : marked_constellation) =
  let rec aux (cs, space) = function
    | [] -> (List.rev cs, List.rev space)
    | (Marked s)::t -> aux (cs, s::space) t
    | (Unmarked s)::t -> aux (s::cs, space) t
  in
  match aux ([], []) mcs with 
  | ([], _) as cfg -> cfg
  | h::t, [] -> (t, [h])
  | _ as cfg -> cfg

let concealing =
  List.filter ~f:(List.for_all ~f:(Fn.compose not is_polarised))

(* counter used for renaming with unique identifiers *)
let counter = ref 0

let raymatcher ?(withloops=true) r r' : substitution option =
  if is_polarised r && is_polarised r' then
    solution ~withloops [(r, r')]
  else None

let self_interaction ?(withloops=true) ?(showtrace=false) (r, other_rays)
: star list =
  let open Out_channel in
  let rec select_ray accr = function
    | [] -> []
    | r'::s' when not (is_polarised r') -> select_ray (r'::accr) s'
    | r'::s' ->
      if showtrace then begin
        output_string stdout "try self ";
        string_of_ray r' |> output_string stdout;
        output_string stdout "... "
      end;
      begin match raymatcher ~withloops r r' with
      | None ->
        if showtrace then output_string stdout "failed.\n";
        select_ray (r'::accr) s'
      | Some theta ->
        if showtrace then begin
          output_string stdout "success with ";
          string_of_subst theta |> output_string stdout;
          output_string stdout ".\n"
        end;
        (List.map (accr@s') ~f:(subst theta))
        :: (select_ray (r'::accr) s')
      end
  in select_ray [] other_rays

let search_partners ?(withloops=true) ?(showtrace=false) (r, other_rays) cs
: star list =
  let open Out_channel in
  let rec select_star accs = function
    | [] -> []
    | s::cs' ->
      let rec select_ray accr = function
        | [] -> []
        | r'::s' when not (is_polarised r') -> (select_ray (r'::accr) s') 
        | r'::s' ->
          if showtrace then begin
            output_string stdout "try ";
            string_of_ray r' |> output_string stdout;
            output_string stdout "... "
          end;
          let i1 = !counter in
          let i2 = (!counter)+1 in
          let renamed_r = replace_indices i1 r in
          let renamed_r' = replace_indices i2 r' in
          match raymatcher ~withloops renamed_r renamed_r' with
          | None ->
              if showtrace then output_string stdout "failed.\n";
            select_ray (r'::accr) s';
          | Some theta ->
            if showtrace then begin
              output_string stdout "success with ";
              string_of_subst theta |> output_string stdout;
              output_string stdout ".\n"
            end;
            counter := !counter + 2;
            let s1 = List.map other_rays ~f:(replace_indices i1) in
            let s2 = List.map (accr@s') ~f:(replace_indices i2) in
            List.map (s1@s2) ~f:(subst theta)
            :: (select_ray (r'::accr) s')
      in (select_ray [] s) @ (select_star (s::accs) cs')
  in select_star [] cs

(* selects only one ray for which interaction is possible *)
let interaction ?(withloops=true) ?(showtrace=false) ?(selfint=false) cs space =
  let open Out_channel in
  let rec select_star accs = function
    | [] -> None
    | s::space' ->
      let rec select_ray accr = function
        | [] -> None
        | r::s' when not (is_polarised r) -> select_ray (r::accr) s'
        | r::s' ->
          if showtrace then begin
            output_string stdout ">>>>> focus on ray ";
            (string_of_ray r |> output_string stdout);
            output_string stdout " of @";
            (string_of_star s |> output_string stdout);
            output_string stdout "\n";
          end;
          let new_stars =
            search_partners ~withloops ~showtrace (r, accr@s') (cs@space')
            |>
            if selfint then
              List.append (self_interaction ~withloops ~showtrace (r, accr@s')) 
            else
              Fn.id
            in
          if List.is_empty new_stars then select_ray (r::accr) s'
          else Some new_stars
      in let new_stars = select_ray [] s in
      if Option.is_none new_stars then select_star (s::accs) space'
      else Some (accs@space'@(Option.value_exn new_stars))
  in select_star [] space

let display_steps content =
  let open Out_channel in
  string_of_constellation content ^ "\n"
  |> output_string stdout;
  flush stdout;
  let _ = In_channel.input_line In_channel.stdin in ()

let exec
  ?(unfincomp=false)
  ?(withloops=true)
  ?(showtrace=false)
  ?(selfint=false)
  ?(showsteps=false)
  (cs, space) : constellation =
  let open Out_channel in
  let rec aux (cs, space) =
    (if showtrace then output_string stdout "\n_____result_____\n");
    (if showsteps || showtrace then display_steps space);
    let result = interaction ~withloops ~showtrace ~selfint cs space in
    (if Option.is_none result then space
    else aux (cs, Option.value_exn result))
  in aux (cs, space)
    |> (if unfincomp then Fn.id else concealing)
    |> if showtrace || showsteps then
      (fun x ->
        (if showtrace then output_string stdout "\n");
        (output_string stdout "_____result_____\n");
        (display_steps x); x) else Fn.id
