open Tools

module type Signature = sig
	type idvar
	type idfunc
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

type substitution = (Sig.idvar * term) list
type equation = term * term
type problem = equation list

let rec fold_term fnode fbase acc = function
	| Var x -> fbase x acc
	| Func (f, ts) ->
		let acc' = fnode f acc in
		List.fold_left (fold_term fnode fbase) acc' ts
		
let rec map_term fnode fbase = function
	| Var x -> fbase x
	| Func (g, ts) ->
		Func (fnode g, List.map (map_term fnode fbase) ts)

let skip = fun _ acc -> acc

let exists_term_vars p t = fold_term skip (fun y acc -> p y || acc) false t
let all_term_vars p t = fold_term skip (fun y acc -> p y && acc) true t
let exists_term_func p t = fold_term (fun y acc -> p y || acc) skip false t
let all_term_func p t = fold_term (fun y acc -> p y && acc) skip true t

let occurs x t = exists_term_vars (fun y -> x=y) t

let extends_vars (i : int) =
	map_term (fun x -> x) (fun x -> Var (Sig.concat x (string_of_int i)))

let vars t = fold_term skip List.cons [] t
  
let apply sub x = try List.assoc x sub with Not_found -> Var x  
let rec subst sub = map_term (fun x -> x) (apply sub) 

(* ---------------------------------------
   Unification algorithm
   --------------------------------------- *)

let rec solve ?(withloops=true) sub : problem -> substitution option = function
  | [] -> Some sub
  (* Clear *)
  | (Var x, Var y)::pbs when x = y ->
	if withloops then solve ~withloops sub pbs else None
  (* Orient + Replace *)
  | (Var x, t)::pbs | (t, Var x)::pbs -> elim ~withloops x t pbs sub
  (* Open *)
  | (Func (f, ts), Func (g, us))::pbs when Sig.compatible f g ->
	begin try solve ~withloops sub ((List.combine ts us)@pbs)
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
	let new_prob = List.map (lift_pair (subst [(x, t)])) pbs in
	let new_sub = (x, t) :: List.map (lift_pairr (subst [(x, t)])) sub in
	solve ~withloops new_sub new_prob
	
let solution ?(withloops=true) : problem -> substitution option = solve ~withloops []

end