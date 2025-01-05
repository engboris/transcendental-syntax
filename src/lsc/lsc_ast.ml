open Base
open Pretty

type polarity = Pos | Neg | Null

module StellarSig = struct
  type idvar = string * int option
  type idfunc = polarity * string
  let equal_idvar (s, i) (s', i') =
    match i, i' with
    | None, None -> equal_string s s'
    | Some j, Some j' ->
      equal_string (s ^ Int.to_string j) (s' ^ Int.to_string j')
    | None, Some j' ->
      equal_string s (s' ^ Int.to_string j')
    | Some j, None ->
      equal_string (s ^ Int.to_string j) s'

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
let equal_constellation = List.equal equal_star

let to_var x = Var (x, None)
let to_func (pf, ts) = Func (pf, ts)

let pos f = (Pos, f)
let neg f = (Neg, f)
let null f = (Null, f)

let muted pf = (Muted, pf)
let noisy pf = (Noisy, pf)

let gfunc c ts = Func (c, ts)
let pfunc f ts = gfunc (muted (pos f)) ts
let nfunc f ts = gfunc (muted (neg f)) ts
let func f ts = gfunc (muted (null f)) ts
let var x = Var x
let pconst f = pfunc f []
let nconst f = nfunc f []
let const f = func f []
let dot t u = nfunc ":" [t; u]

let is_polarised r : bool =
  let aux = function
  | (_, (Pos, _)) | (_, (Neg, _)) -> true
  | _ -> false
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

let string_of_polsym (m, (p, f)) =
  match m with
  | Noisy -> (string_of_polarity p) ^ "#" ^ f
  | Muted -> (string_of_polarity p) ^ f

let string_of_var (x, i) =
  match i with
  | None -> x
  | Some i' -> x ^ (Int.to_string i')

let rec string_of_ray = function
  | Var xi -> string_of_var xi
  | Func (pf, []) -> string_of_polsym pf
  | Func ((_, (Null, ":")), [Func ((_, (Null, ":")), [r1; r2]); r3]) ->
    "(" ^ (string_of_ray r1) ^ ":"  ^ (string_of_ray r2) ^ "):" ^
    (string_of_ray r3)
  | Func ((_, (Null, ":")), [r1; r2]) ->
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

let equal_mstar ms ms' = match ms, ms' with
  | Marked s, Marked s' | Unmarked s, Unmarked s' ->
    equal_star s s'
  | _ -> false

let equal_mconstellation = List.equal equal_mstar

let map_mstar ~f : marked_star -> marked_star = function
  | Marked s -> Marked (List.map ~f:f s)
  | Unmarked s -> Unmarked (List.map ~f:f s)

let subst_all_vars sub  = List.map ~f:(map_mstar ~f:(subst sub))
let subst_all_funcs sub = List.map ~f:(map_mstar ~f:(replace_funcs sub))

let unmark = function s -> Unmarked s
let mark = function s -> Marked s
let focus = List.map ~f:(fun r -> mark r)

let remove_mark = function
  | Marked s -> s
  | Unmarked s -> s

let unmark_all = List.map ~f:(fun s -> Unmarked s)
let remove_mark_all = List.map ~f:remove_mark

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

let rec saturation queue marked remains =
  match queue with
  | [] -> (marked, remains)
  | h::t ->
    let (marked', remains') = List.partition_tf remains ~f:(connectable h) in
    saturation (marked'@t) (h::marked) remains'

let cc_representatives from cs =
  let rec selection reps marked remains =
    match remains with
    | [] -> (marked, reps)
    | h::t ->
      let (marked', remains') = List.partition_tf t ~f:(connectable h) in
      let (marked'', remains'') = saturation marked' marked remains' in
      selection (h::reps) marked'' remains''
  in selection [] from cs

let extract_intspace (mcs : marked_constellation) =
  let rec sort (cs, space) = function
    | [] -> (List.rev cs, List.rev space)
    | (Marked s)::t -> sort (cs, s::space) t
    | (Unmarked s)::t -> sort (s::cs, space) t
  in
  match sort ([], []) mcs with
  (* autonomous interaction *)
  | unmarked, [] -> cc_representatives [] unmarked
  (* directed interaction *)
  | unmarked, marked ->
    let (marked', remains) = saturation marked [] unmarked in
    let (cs, reps) = cc_representatives marked' remains in
    ident_counter := 0;
    (cs, reps@marked)

(* ---------------------------------------
   Interactive execution
   --------------------------------------- *)

let unpolarized_star = List.for_all ~f:(Fn.compose not is_polarised)
let kill = List.filter ~f:unpolarized_star
let clean = List.filter ~f:List.is_empty

let pairs_with_rest l =
  let rec aux acc = function
    | [] -> []
    | h::t -> (h, acc@t) :: aux (acc@[h]) t
  in aux [] l

let fusion repl1 repl2 s1 s2 theta =
  let new1 = List.map s1 ~f:repl1 in
  let new2 = List.map s2 ~f:repl2 in
  List.map (new1@new2) ~f:(subst theta)

(* co-branching : useless ?
let connexions (r, other_rays) stars =
  let rec select_ray acc other_rays' repl1 repl2 = function
    | [] -> acc
    | r'::remains ->
      match raymatcher (repl1 r) (repl2 r') with
      | None -> select_ray acc (r'::other_rays') repl1 repl2 remains
      | Some theta ->
        let res = fusion repl1 repl2 other_rays other_rays' theta in
        ident_counter := !ident_counter + 2;
        select_ray (res::acc) (r'::other_rays') repl1 repl2 remains
  in
  let repl1 = replace_indices !ident_counter in
  List.concat_map stars ~f:(fun s ->
    let repl2 = replace_indices (!ident_counter+1) in
    select_ray [] [] repl1 repl2 s
  )
*)

let search_partners ?(showtrace=false) (r, other_rays) candidates
: star list =
  let open Out_channel in
  let print_string = output_string stdout in
  let rec select_ray queue other_stars repl1 repl2 = function
    | [] -> []
    | r'::s' when not (is_polarised r') ->
        select_ray (r'::queue) other_stars repl1 repl2 s'
    | r'::s' ->
      if showtrace then begin
        print_string "try ";
        string_of_ray r' |> print_string;
        print_string "... "
      end;
      match raymatcher (repl1 r) (repl2 r') with
      | None ->
        if showtrace then print_string "failed.\n";
        select_ray (r'::queue) other_stars repl1 repl2 s'
      | Some theta ->
        if showtrace then begin
          print_string "success with ";
          string_of_subst theta |> print_string;
          print_string ".\n"
        end;
        let other_rays' = queue@s' in
        let res = fusion repl1 repl2 other_rays other_rays' theta
        :: (* (connexions (r', other_rays') other_stars) @ *)
           (select_ray (r'::queue) other_stars repl1 repl2 s') in
        ident_counter := !ident_counter + 2;
        res
  in
  let repl1 = replace_indices !ident_counter in
  pairs_with_rest candidates
    |> List.concat_map ~f:(fun (s, cs) ->
      let repl2 = replace_indices (!ident_counter+1) in
      select_ray [] cs repl1 repl2 s
    )

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
  let print_string = output_string stdout in
  let rec aux (cs, space) =
    (if showtrace then print_string "\n_____result_____\n");
    (if showsteps || showtrace then display_steps space);
    begin match interaction ~showtrace cs space with
    | None -> space
    | Some result' -> aux (cs, result')
    end
  in aux (extract_intspace mcs)
    |> if showtrace || showsteps then
      (fun x ->
        (if showtrace then print_string "\n");
        (print_string "_____result_____\n");
        (display_steps x); x) else Fn.id
