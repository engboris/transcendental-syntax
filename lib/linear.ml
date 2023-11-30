open Stellar

type term =
  | Var of string
  | Lam of (string * term)
  | App of (term * term)

let gterm pol f : ray = gfunc (pol, f) [var "X"] 
let addl = dot (nconst "l")
let addr = dot (nconst "r")

type vehicle = {
  body : constellation;
  out  : ray
}

(* let rec constellation_of_term t : vehicle =
  match t with
  | Var x -> { body = [[gterm Pos x; gterm Pos ("~"^x)]]; out = gterm Pos x }
  | Lam (x, t') ->
    let rx = gterm Pos x in
    let dual_rx = gterm Pos ("~"^x) in
    let is1 = Option.get (List.find_index (List.mem rx) (constellation_of_terms t') in
    let is2 = Option.get (List.find_index (List.mem dual_rx) cs1) in *)

type type_label =
  | PAtom of string
  | NAtom of string
  | Tensor of (type_label * type_label)
  | Par of (type_label * type_label)

let rec string_of_type = function
  | PAtom x -> x
  | NAtom x -> "~"^x
  | Tensor (t1, t2) ->
    "(" ^ string_of_type t1 ^ " * " ^ string_of_type t2 ^ ")"
  | Par (t1, t2) ->
    "(" ^ string_of_type t1 ^ " | " ^ string_of_type t2 ^ ")"

let tensor t1 t2 : constellation =
  [[gterm Neg (string_of_type t1); gterm Neg (string_of_type t2);
    gterm Pos (string_of_type (Tensor (t1, t2)))]]

let parl t1 t2 : constellation =
  [[gterm Neg (string_of_type t1); gterm Pos (string_of_type (Par (t1, t2)))];
  [gterm Neg (string_of_type t2)]]

let parr t1 t2 : constellation =
  [[gterm Neg (string_of_type t1)];
  [gterm Neg (string_of_type t2); gterm Pos (string_of_type (Par (t1, t2)))]]

let rec tests_of_type t : constellation list =
  let aux : type_label -> constellation list = function
    | PAtom _ | NAtom _ -> []
    | Par (t1, t2) ->
      (parl t1 t2 :: (tests_of_type t1 @ tests_of_type t2)) @
      (parr t1 t2 :: (tests_of_type t1 @ tests_of_type t2))
    | Tensor (t1, t2) ->
      tensor t1 t2 :: (tests_of_type t1 @ tests_of_type t2)
  in let cstar = [gterm Neg (string_of_type t); gterm Null (string_of_type t)] in 
  List.map (List.cons cstar) (aux t)

let rec ports_of_type t : ray list = match t with 
  | PAtom _ | NAtom _ -> [gterm Pos (string_of_type t)]
  | Tensor (t1, t2) | Par (t1, t2) -> ports_of_type t1 @ ports_of_type t2
