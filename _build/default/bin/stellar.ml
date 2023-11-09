type polarity = Pos | Neg | Null

let string_of_polarity = function
	| Pos -> "+"
	| Neg -> "-"
	| Null -> ""
	
let string_of_polsym (p, f) = (string_of_polarity p) ^ f

module StellarSig = struct
	type idvar = string
	type idfunc = polarity * string
	let concat = (^)
	let compatible f g =
		match f, g with
		| (Pos, f), (Neg, g)
		| (Neg, f), (Pos, g) when f = g -> true
		| (Null, f), (Null, g) when f = g -> true
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

let pfunc f ts = Func (pos f, ts)
let nfunc f ts = Func (neg f, ts)
let func f ts = Func (null f, ts)
let var x = Var x
let pconst f = pfunc f []
let nconst f = nfunc f []
let const f = func f []

let is_polarised r : bool =
	let aux = (function
		| (Pos, _) | (Neg, _) -> true
		| (Null, _) -> false)
	in exists_term_func aux r

(* ---------------------------------------
   Display
   --------------------------------------- *)
	
let rec string_of_list printer sep = function
	| [] -> ""
	| [x] -> printer x
	| h::t ->
		(printer h) ^ sep ^ (string_of_list printer sep t)

let rec string_of_ray = function
	| Var x -> x
	| Func (pf, []) -> string_of_polsym pf
	| Func ((Null, "."), [r1; r2]) ->
		(string_of_ray r1) ^ " · " ^ (string_of_ray r2)
	| Func (pf, ts) -> string_of_polsym pf ^
		"(" ^ (string_of_list string_of_ray ", " ts) ^ ")"
		
let string_of_subst sub =
	"{" ^ 
	(List.fold_left (
		fun _ (x, r) -> x ^ "->" ^ (string_of_ray r)
	) "" sub) ^
	"}"
		
let string_of_star s = "[" ^ (string_of_list string_of_ray ", " s) ^ "]"

let string_of_constellation cs =
	if cs = [] then "{}" else string_of_list string_of_star " + " cs
	
let string_of_configuration (cs, space) =
	(string_of_constellation cs) ^ " |- " ^ (string_of_constellation space)

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

let counter = ref 0
	
let raymatcher ?(withloops=true) r r' : substitution option =
	if is_polarised r && is_polarised r' then
		solution ~withloops [(r, r')]
	else
		None

let self_interaction ?(withloops=true) (r, other_rays) : star list =
	let rec auxr accr s = match s with
		| [] -> []
		| r'::s' when not (is_polarised r') -> (auxr (r'::accr) s') 
		| r'::s' ->
			match raymatcher ~withloops r r' with
			| None -> auxr (r'::accr) s'
			| Some theta -> (List.map (subst theta) (accr@s')) :: (auxr (r'::accr) s')
	in auxr [] other_rays

let search_partners ?(withloops=true) (r, other_rays) cs : star list =
	(* star selection, [] means no star partner *)
	let rec auxs accs cs = match cs with
		| [] -> []
		| s::cs' ->
			(* ray selection, [] means no ray partner in s *)
			let rec auxr accr s = match s with
				| [] -> []
				| r'::s' when not (is_polarised r') -> (auxr (r'::accr) s') 
				| r'::s' ->
					let c1 = !counter in
					let c2 = (!counter)+1 in
					let renamed_r = extends_vars c1 r in
					let renamed_r' = extends_vars c2 r' in
					match raymatcher ~withloops renamed_r renamed_r' with
					| None -> auxr (r'::accr) s'
					| Some theta ->
						counter := !counter + 2;
						let s1 = List.map (extends_vars c1) other_rays in
						let s2 = List.map (extends_vars c2) (accr@s') in
						(List.map (subst theta) (s1@s2)) :: (auxr (r'::accr) s')
			in (auxr [] s) @ (auxs (s::accs) cs')
	in auxs [] cs

(* selects only one ray for which interaction is possible *)
let interaction ?(withloops=true) cs space =
	(* star selection *)
	let rec auxs accs space = match space with
		| [] -> None
		| s::space' ->
			(* ray selection *)
			let rec auxr accr s = match s with
				| [] -> None
				| r::s' when not (is_polarised r) -> auxr (r::accr) s'
				| r::s' ->
					let new_stars =
						self_interaction ~withloops (r, accr@s')
						@ search_partners ~withloops (r, accr@s') cs in
					if new_stars=[] then auxr (r::accr) s' else Some new_stars
			in let new_stars = auxr [] s in
			if Option.is_none new_stars then auxs (s::accs) space'
			else Some (accs@space'@(Option.get new_stars))
	in auxs [] space

let rec exec ?(withloops=true) (cs, space) : constellation =
	let result = interaction ~withloops cs space in
	if Option.is_none result then space
	else exec ~withloops (cs, Option.get result)
