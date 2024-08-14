open Base
open Lsc_ast

type ident = string

type stellar_expr =
  | Raw of marked_constellation
  | Id of ident
  | Int of stellar_expr * stellar_expr

type env = (ident * stellar_expr) list

type command =
  | PrintStellar of stellar_expr
  | PrintMessage of string

type declaration =
  | Def of ident * stellar_expr
  | Command of command

type program = declaration list

let rec eval_stellar_expr (env : env)
  : stellar_expr -> marked_constellation = function
  | Raw mcs -> mcs
  | Id x ->
    List.Assoc.find_exn ~equal:equal_string env x
    |> eval_stellar_expr env
  | Int (e, e') ->
    let mcs  = eval_stellar_expr env e  in
    let mcs' = eval_stellar_expr env e' in
    let cs = extract_intspace (mcs@mcs') in
    exec ~unfincomp:false ~withloops:false ~showtrace:false
         ~selfint:false ~showsteps:false cs
    |> List.map ~f:(fun x -> Unmarked x)

let eval_command env = function
  | PrintStellar e ->
    eval_stellar_expr env e
    |> List.map ~f:unmark
    |> string_of_constellation
    |> Stdlib.print_string;
    Stdlib.print_newline ();
    env
  | PrintMessage m ->
    Stdlib.print_string m;
    Stdlib.print_newline ();
    env

let eval_decl env : declaration -> env = function
  | Def (x, e) -> List.Assoc.add ~equal:equal_string env x e
  | Command c -> eval_command env c

let eval_program p =
  List.fold_left ~f:(fun acc x -> eval_decl acc x) ~init:[] p
