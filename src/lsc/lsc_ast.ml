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
let equal_star = List.equal equal_ray

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

let raymatcher r r' : substitution option =
  if is_polarised r && is_polarised r' then solution [(r, r')]
  else None

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
   Operation on marked stars
   --------------------------------------- *)

type marked_star = Marked of star | Unmarked of star
type marked_constellation = marked_star list

let map_mstar ~f : marked_star -> marked_star = function
  | Marked s -> Marked (List.map ~f:f s)
  | Unmarked s -> Unmarked (List.map ~f:f s)

let subst_all_vars sub = List.map ~f:(map_mstar ~f:(subst sub))
let subst_all_funcs sub = List.map ~f:(map_mstar ~f:(replace_funcs sub))

let unmark = function s -> Unmarked s

let remove_mark = function
  | Marked s -> s
  | Unmarked s -> s

let unmark_all = List.map ~f:(fun s -> Unmarked s)
let remove_mark_all = List.map ~f:remove_mark

let unpolarized_mstar ms =
  remove_mark ms
  |> List.for_all ~f:(Fn.compose not is_polarised)

let ident_counter = ref 0

let connectable (s1 : star) (s2 : star) : bool =
  let (>>=) = List.Monad_infix.(>>=) in
  begin
    s1 >>= fun r1 ->
    s2 >>= fun r2 ->
    let renamed_r  = replace_indices !ident_counter r1 in
    let renamed_r' = replace_indices (!ident_counter+1) r2 in
    let matching = raymatcher renamed_r renamed_r' in
    if Option.is_some matching then (ident_counter := !ident_counter+1);
    [matching]
  end
  |> List.exists ~f:Option.is_some

let cc_representatives cs =
  let rec saturation queue marked remains =
    match queue with
    | [] -> (marked, remains)
    | h::t ->
      let (marked', remains') = List.partition_tf remains ~f:(connectable h) in
      saturation (marked'@t) (h::marked) remains'
  in
  let rec selection reps marked remains =
    match remains with
    | [] -> (marked, reps)
    | h::t ->
      let (marked', remains') = List.partition_tf t ~f:(connectable h) in
      let (marked'', remains'') = saturation marked' marked remains' in
      selection (h::reps) marked'' remains''
  in selection [] [] cs

let extract_intspace (mcs : marked_constellation) =
  let rec aux (cs, space) = function
    | [] -> (List.rev cs, List.rev space)
    | (Marked s)::t -> aux (cs, s::space) t
    | (Unmarked s)::t -> aux (s::cs, space) t
  in
  match aux ([], []) mcs with
  (* autonomous interaction *)
  | cs, [] -> cc_representatives cs
  (* directed interaction *)
  | _ as cfg -> cfg

(* ---------------------------------------
   Interactive execution
   --------------------------------------- *)

let unpolarized_star = List.for_all ~f:(Fn.compose not is_polarised)
let concealing = List.filter ~f:unpolarized_star

let search_partners ?(showtrace=false) (r, other_rays) candidates
: star list =
  let open Out_channel in
  let rec select_ray queue = function
    | [] -> []
    | r'::s' when not (is_polarised r') -> select_ray (r'::queue) s'
    | r'::s' ->
      if showtrace then begin
        output_string stdout "try ";
        string_of_ray r' |> output_string stdout;
        output_string stdout "... "
      end;
      let i1 = !ident_counter in
      let i2 = !ident_counter + 1 in
      let renamed_r = replace_indices i1 r in
      let renamed_r' = replace_indices i2 r' in
      match raymatcher renamed_r renamed_r' with
      | None ->
        if showtrace then output_string stdout "failed.\n";
        select_ray (r'::queue) s'
      | Some theta ->
        if showtrace then begin
          output_string stdout "success with ";
          string_of_subst theta |> output_string stdout;
          output_string stdout ".\n"
        end;
        ident_counter := !ident_counter + 2;
        let s1 = List.map other_rays ~f:(replace_indices i1) in
        let s2 = List.map (queue@s') ~f:(replace_indices i2) in
        List.map (s1@s2) ~f:(subst theta)
        :: (select_ray (r'::queue) s')
  in List.concat_map ~f:(select_ray []) candidates

let interaction ?(showtrace=false) cs space =
  let rec interact_on_rays space' queue = function
    | [] -> None
    | r::rs when not (is_polarised r) -> interact_on_rays space' (r::queue) rs
    | r::rs ->
      begin match search_partners ~showtrace (r, queue@rs) (cs@space') with
      | [] -> interact_on_rays space' (r::queue) rs
      | new_stars -> Some new_stars
      end
  in
  let rec fst_interaction_on_star queue = function
    | [] -> None
    | s::space' ->
      begin match interact_on_rays space' [] s with
      | None -> fst_interaction_on_star (s::queue) space'
      | Some new_stars -> Some ((List.rev queue)@space'@new_stars)
      end
  in fst_interaction_on_star [] space

let display_steps content =
  let open Out_channel in
  string_of_constellation content ^ "\n"
  |> output_string stdout;
  flush stdout;
  let _ = In_channel.input_line In_channel.stdin in ()

let exec ?(showtrace=false) ?(showsteps=false) mcs =
  let open Out_channel in
  let rec aux (cs, space) =
    (if showtrace then output_string stdout "\n_____result_____\n");
    (if showsteps || showtrace then display_steps space);
    begin match interaction ~showtrace cs space with
    | None -> space
    | Some result' -> aux (cs, result')
    end
  in aux (extract_intspace mcs)
    |> if showtrace || showsteps then
      (fun x ->
        (if showtrace then output_string stdout "\n");
        (output_string stdout "_____result_____\n");
        (display_steps x); x) else Fn.id
