open Tools
open Base

module type Signature = sig
	type idvar
	type idfunc
	val equal_idvar : idvar -> idvar -> bool
	val concat : idvar -> string -> idvar
	val compatible : idfunc -> idfunc -> bool
	val string_of_idfunc : idfunc -> string
end

(* ---------------------------------------
   Elementary definitions
   --------------------------------------- *)

module Make (Sig : Signature) = struct

type term =
	| Var of Sig.idvar
	| Func of (Sig.idfunc * term list)
	[@@deriving equal, compare]

type substitution = (Sig.idvar * term) list
type equation = term * term
type problem = equation list

let rec fold fnode fbase acc = function
	| Var x -> fbase x acc
	| Func (f, ts) ->
		let acc' = fnode f acc in
		List.fold ts ~init:acc' ~f:(fold fnode fbase)
		
let rec map fnode fbase = function
	| Var x -> fbase x
	| Func (g, ts) ->
		Func (fnode g, List.map ~f:(map fnode fbase) ts)

let skip = fun _ acc -> acc

let exists_var pred t = fold skip (fun y acc -> pred y || acc) false t
let for_all_var pred t = fold skip (fun y acc -> pred y && acc) true t
let exists_func pred t = fold (fun y acc -> pred y || acc) skip false t
let for_all_func pred t = fold (fun y acc -> pred y && acc) skip true t

let occurs x t = exists_var (fun y -> Sig.equal_idvar x y) t

let extends_vars (i : int) =
	map Fn.id (fun x -> Var (Sig.concat x (Int.to_string i)))

let vars t = fold skip List.cons [] t
  
let apply sub x =
	match List.Assoc.find sub ~equal:Sig.equal_idvar x with
	| None -> Var x
	| Some t -> t

let subst sub = map Fn.id (apply sub) 

(* ---------------------------------------
   Unification algorithm
   --------------------------------------- *)

let rec solve ?(withloops=true) sub : problem -> substitution option = function
	| [] -> Some sub
	(* Clear *)
	| (Var x, Var y)::pbs when Sig.equal_idvar x y ->
	if withloops then solve ~withloops sub pbs else None
	(* Orient + Replace *)
	| (Var x, t)::pbs | (t, Var x)::pbs -> elim ~withloops x t pbs sub
	(* Open *)
	| (Func (f, ts), Func (g, us))::pbs when Sig.compatible f g ->
	begin try solve ~withloops sub ((List.zip_exn ts us)@pbs)
	with Invalid_argument _ ->
		failwith (
			"Unification error on symbols " ^
			(Sig.string_of_idfunc f) ^
			" and " ^
			(Sig.string_of_idfunc g))
	end
	| _ -> None
(* Replace *)
and elim ?(withloops=true) x t pbs sub : substitution option =
	if occurs x t then None (* Circularity *)
	else
	let new_prob = List.map ~f:(lift_pair (subst [(x, t)])) pbs in
	let new_sub = (x, t) :: List.map ~f:(lift_pairr (subst [(x, t)])) sub in
	solve ~withloops new_sub new_prob
	
let solution ?(withloops=true) : problem -> substitution option = solve ~withloops []

end
