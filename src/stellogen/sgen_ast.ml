open Base
open Lsc_ast

type ident = string
type spec_ident = string
type pred_ident = string

type stellar_expr =
  | Raw of marked_constellation
  | Id of ident
  | Exec of stellar_expr
  | Union of stellar_expr * stellar_expr

type test = spec_ident * stellar_expr

type env = {
  objs: (ident * stellar_expr) list;
  specs: (spec_ident * test list) list;
}

type declaration =
  | Def of ident * stellar_expr
  | Spec of ident * test list
  | Typecheck of ident * spec_ident * pred_ident
  | PrintStellar of stellar_expr
  | PrintMessage of string

type program = declaration list

let add_obj env x e = List.Assoc.add ~equal:equal_string env.objs x e
let add_spec env x e = List.Assoc.add ~equal:equal_string env.specs x e
let get_obj env x = List.Assoc.find_exn ~equal:equal_string env.objs x
let get_spec env x = List.Assoc.find_exn ~equal:equal_string env.specs x

let rec eval_stellar_expr (env : env)
  : stellar_expr -> marked_constellation = function
  | Raw mcs -> mcs
  | Id x ->
    begin try
      get_obj env x |> eval_stellar_expr env
    with Sexplib0__Sexp.Not_found_s _ ->
      failwith ("Error: undefined identifier " ^ x ^ ".");
    end
  | Union (e, e') ->
    (eval_stellar_expr env e) @ (eval_stellar_expr env e')
  | Exec e  ->
    let mcs = eval_stellar_expr env e in
    let cs = extract_intspace mcs in
    exec ~unfincomp:false ~withloops:false ~showtrace:false
         ~selfint:false ~showsteps:false cs
    |> unmark_all

let eval_decl env : declaration -> env = function
  | Def (x, e) -> { objs=add_obj env x e; specs=env.specs }
  | Spec (x, es) -> { objs=env.objs; specs=add_spec env x es }
  | Typecheck (ics, t, ipred) ->
    let mcs = get_obj env ics |> eval_stellar_expr env in
    let pred = get_obj env ipred |> eval_stellar_expr env in
    let etests = get_spec env t in
    let prepare : marked_constellation -> marked_constellation =
      List.map ~f:(fun ms -> map_mstar ~f:(fun r -> pfunc "test?" [r]) ms) in
    let interaction x y =
      Exec (Union (Raw x, Raw y)) |> eval_stellar_expr env in
    let test_with x t' =
      let res = interaction x t' in
      let prepared = prepare res in
      interaction prepared pred
    in
    let all_rays_ok rays = List.for_all ~f:(equal_ray (const "ok")) rays in
    if not @@ List.for_all ~f:(fun (_, et') ->
      let t' = eval_stellar_expr env et' in
      let res : marked_constellation = test_with mcs t' in
      all_rays_ok (List.concat @@ (remove_mark_all res)) &&
      (not @@ List.is_empty res)
    ) etests then
      failwith (
        "TypeError: '" ^ ics ^
        "' not of type '" ^ t ^ "'."
      );
    env
  | PrintStellar e ->
    eval_stellar_expr env e
    |> List.map ~f:remove_mark
    |> string_of_constellation
    |> Stdlib.print_string;
    Stdlib.print_newline ();
    env
  | PrintMessage m ->
    Stdlib.print_string m;
    Stdlib.print_newline ();
    env

let eval_program p =
  let empty_env = { objs=[]; specs=[] } in
  List.fold_left
  ~f:(fun acc x -> eval_decl acc x)
  ~init:empty_env p
