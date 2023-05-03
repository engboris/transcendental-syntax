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

open StellarSig
open StellarRays
open Tools

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

let rec is_polarised r : bool =
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
		fun acc (x, r) -> x ^ "->" ^ (string_of_ray r)
	) "" sub) ^
	"}"
		
let string_of_star s = "[" ^ (string_of_list string_of_ray ", " s) ^ "]"

let string_of_constellation cs =
	if cs = [] then "{}" else string_of_list string_of_star " + " cs
	
let string_of_intspace (cs, space) =
	(string_of_constellation cs) ^ " |- " ^ (string_of_constellation space)

(* ---------------------------------------
   Interactive execution
   --------------------------------------- *)
	
let raymatcher ?(withloops=true) r r' : substitution option =
	if is_polarised r && is_polarised r' then
		solution ~withloops [(r, r')]
	else
		None

let interaction ?(withloops=true) (s : star) i j (cs : constellation) : constellation = 
	cs >>= fun i' s' ->
	let s = List.map (extends_vars i) s in
	let s' = List.map (extends_vars i') s' in
	s' >>= fun j' r' ->
	match raymatcher ~withloops (List.nth s j) r' with
	| None -> []
	| Some sub ->
		let s1 = without j s in
		let s2 = without j' s' in
		return (List.map (subst sub) (s1@s2))

let intspace ?(withloops=true) cs space : constellation =
	List.flatten (
		space >>= fun i s ->
		s >>= fun j _ ->
		return (interaction ~withloops s i j (cs@space))
	)

let rec intexec ?(withloops=true) (cs, space) : constellation =
	let result = intspace ~withloops cs space in
	if result = [] then space
	else intexec ~withloops (cs, result)