open Base

type polarity = Pos | Neg | Null

let string_of_polarity = function
	| Pos -> "+"
	| Neg -> "-"
	| Null -> ""
	
let string_of_polsym (p, f) = (string_of_polarity p) ^ f

module StellarSig = struct
	type idvar = string
	type idfunc = polarity * string
  let equal_idvar = equal_string
	let concat = (^)
	let compatible f g =
		match f, g with
		| (Pos, f), (Neg, g)
		| (Neg, f), (Pos, g) -> equal_string f g
		| (Null, f), (Null, g) -> equal_string f g
		| _ -> false
	let string_of_idfunc = string_of_polsym
end

module StellarRays = Unification.Make(StellarSig)

open StellarRays

(* ---------------------------------------
   Stars and Constellations
   --------------------------------------- *)

type ray = term
type star = ray list
type constellation = star list

let to_var x = Var x
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
let dot t u = nfunc "." [t; u]

let is_polarised r : bool =
	let aux = function
		| (Pos, _) | (Neg, _) -> true
		| (Null, _) -> false
	in exists_func aux r

(* ---------------------------------------
   Pretty Printer
   --------------------------------------- *)

let surround first last s = first ^ s ^ last

let rec string_of_list printer sep = function
	| [] -> ""
  | [x] -> printer x 
	| h::t ->
    (printer h) ^ sep ^
    (string_of_list printer sep t) 

let rec string_of_ray = function
	| Var x -> x
	| Func (pf, []) -> string_of_polsym pf
	| Func ((Null, "."), [r1; r2]) ->
		(string_of_ray r1) ^ " · " ^ (string_of_ray r2)
	| Func (pf, ts) -> string_of_polsym pf ^
    surround "(" ")" @@ 
		string_of_list string_of_ray ", " ts
		
let string_of_subst sub =
	List.fold sub ~init:"" ~f:(fun _ (x, r) ->
    x ^ "->" ^ (string_of_ray r))
  |> surround "{" "}"
  
let string_of_star s =
  string_of_list string_of_ray ", " s
  |> surround "[" "]"

let string_of_constellation cs =
	if List.is_empty cs then "{}"
  else string_of_list string_of_star " + " cs
	
let string_of_configuration (cs, space) =
	(string_of_constellation cs) ^ " |- " ^
  (string_of_constellation space)

(* ---------------------------------------
   Interactive execution
   --------------------------------------- *)
(*
The expressions which are evaluated are "stellar configurations" :
reference constellation |- interaction space

1. Select a ray 'r' in a star 's' of the interaction space
2. Look for possible connexions with rays 'ri' in stars 'si'
   in the reference constellation and in 's'
3. Duplicate 's' for each 'ri' and make them interact
4. In case of co-branching ('ri' matchable with other 'rk')
	 interaction is not defined
	 (we will avoid such constellations in this version)
*)

(* counter used for renaming with unique identifiers *)
let counter = ref 0
	
let raymatcher ?(withloops=true) r r' : substitution option =
	if is_polarised r && is_polarised r' then
		solution ~withloops [(r, r')]
	else None

let self_interaction ?(withloops=true) (r, other_rays) : star list =
	let rec select_ray accr = function
		| [] -> []
		| r'::s' when not (is_polarised r') -> select_ray (r'::accr) s' 
		| r'::s' ->
			begin match raymatcher ~withloops r r' with
			| None -> select_ray (r'::accr) s'
			| Some theta ->
        (List.map (accr@s') ~f:(subst theta))
        :: (select_ray (r'::accr) s')
      end
	in select_ray [] other_rays

let search_partners ?(withloops=true) (r, other_rays) cs : star list =
	(* [] means no star partner *)
	let rec select_star accs = function 
		| [] -> []
		| s::cs' ->
			(* [] means no ray partner in s *)
			let rec select_ray accr = function
				| [] -> []
				| r'::s' when not (is_polarised r') -> (select_ray (r'::accr) s') 
				| r'::s' ->
					let c1 = !counter in
					let c2 = (!counter)+1 in
					let renamed_r = extends_vars c1 r in
					let renamed_r' = extends_vars c2 r' in
					match raymatcher ~withloops renamed_r renamed_r' with
					| None -> select_ray (r'::accr) s'
					| Some theta ->
						counter := !counter + 2;
						let s1 = List.map other_rays ~f:(extends_vars c1) in
						let s2 = List.map (accr@s') ~f:(extends_vars c2) in
						(List.map (s1@s2) ~f:(subst theta))
            :: (select_ray (r'::accr) s')
			in (select_ray [] s) @ (select_star (s::accs) cs')
	in select_star [] cs

(* selects only one ray for which interaction is possible *)
let interaction ?(withloops=true) cs space =
	let rec select_star accs space = match space with
		| [] -> None
		| s::space' ->
			let rec select_ray accr s = match s with
				| [] -> None
				| r::s' when not (is_polarised r) -> select_ray (r::accr) s'
				| r::s' ->
					let new_stars =
						self_interaction ~withloops (r, accr@s')
						@ search_partners ~withloops (r, accr@s') cs in
					if List.is_empty new_stars then select_ray (r::accr) s' else Some new_stars
			in let new_stars = select_ray [] s in
			if Option.is_none new_stars then select_star (s::accs) space'
			else Some (accs@space'@(Option.value_exn new_stars))
	in select_star [] space

let display_steps content =
  string_of_constellation content
  |> Out_channel.output_string Out_channel.stdout;
  Out_channel.flush Out_channel.stdout;
  let _ = In_channel.input_line In_channel.stdin in ()

let rec exec ?(withloops=true) ?(showsteps=false) (cs, space) : constellation =
  let result = interaction ~withloops cs space in
  if Option.is_none result then space
	else
    (if showsteps then display_steps (Option.value_exn result);
    exec ~withloops ~showsteps (cs, Option.value_exn result))
