open Base
open Lsc_ast

type ident = string
type idvar = string * int option
type idfunc = polarity * string

type galaxy =
  | Const of marked_constellation
  | Galaxy of (ident * galaxy_expr) list
and galaxy_expr =
  | Raw of galaxy
  | Access of galaxy_expr * ident
  | Id of ident
  | Exec of galaxy_expr
  | Union of galaxy_expr * galaxy_expr
  | Extend of (StellarRays.fmark * idfunc) * galaxy_expr
  | Reduce of (StellarRays.fmark * idfunc) * galaxy_expr
  | Focus of galaxy_expr
  | SubstVar of ident * StellarRays.term * galaxy_expr
  | SubstFunc of (StellarRays.fmark * idfunc) *
                 (StellarRays.fmark * idfunc) *
                 galaxy_expr
  | SubstGal of ident * galaxy_expr * galaxy_expr
  | Process of galaxy_expr list
  | Token of string
  | Clean

type env = {
  objs  : (ident * galaxy_expr) list;
  types : (ident * (ident * ident option)) list;
}

type declaration =
  | Def of ident * galaxy_expr
  | ShowGalaxy of galaxy_expr
  | PrintGalaxy of galaxy_expr
  | SetOption of ident * bool
  | TypeDef of ident * ident * ident option

type program = declaration list

let showsteps = ref false
let showtrace = ref false
let cleaner = ref false

let add_obj env x e = List.Assoc.add ~equal:equal_string env.objs x e
let get_obj env x = List.Assoc.find_exn ~equal:equal_string env.objs x
let add_type env x e = List.Assoc.add ~equal:equal_string env.types x e
let get_type env x = List.Assoc.find_exn ~equal:equal_string env.types x

let rec map_galaxy env ~f = function
  | Const mcs -> Const (f mcs)
  | Galaxy g -> Galaxy (List.map ~f:(fun (k, v) ->
    (k, map_galaxy_expr env ~f:f v)) g
  )
and map_galaxy_expr env ~f = function
  | Raw g -> Raw (map_galaxy env ~f:f g)
  | Access (e, x) -> Access (map_galaxy_expr env ~f:f e, x)
  | Id x -> get_obj env x
    |> map_galaxy_expr env ~f:f
  | Exec e -> Exec (map_galaxy_expr env ~f:f e)
  | Union (e, e') ->
    Union (map_galaxy_expr env ~f:f e, map_galaxy_expr env ~f:f e')
  | Extend (pf, e) -> Extend (pf, map_galaxy_expr env ~f:f e)
  | Reduce (pf, e) -> Reduce (pf, map_galaxy_expr env ~f:f e)
  | Focus e -> Focus (map_galaxy_expr env ~f:f e)
  | SubstVar (x, r, e) -> SubstVar (x, r, map_galaxy_expr env ~f:f e)
  | SubstFunc (pf, pf', e) -> SubstFunc (pf, pf', map_galaxy_expr env ~f:f e)
  | SubstGal (x, e, e') ->
    SubstGal (x, map_galaxy_expr env ~f:f e, map_galaxy_expr env ~f:f e')
  | Process gs -> Process (List.map ~f:(map_galaxy_expr env ~f:f) gs)
  | Token x -> Token x
  | Clean -> Clean

let rec fill_token env (_from : string) _to = function
  | Raw g -> Raw g
  | Id x -> get_obj env x
    |> fill_token env _from _to
  | Clean -> Clean
  | Access (g, x) -> Access (fill_token env _from _to g, x)
  | Exec e -> Exec (fill_token env _from _to e)
  | Union (e, e') ->
    Union (fill_token env _from _to e, fill_token env _from _to e')
  | Extend (pf, e) -> Extend (pf, fill_token env _from _to e)
  | Reduce (pf, e) -> Reduce (pf, fill_token env _from _to e)
  | Focus e -> Focus (fill_token env _from _to e)
  | SubstVar (x, r, e) -> SubstVar (x, r, fill_token env _from _to e)
  | SubstFunc (pf, pf', e) ->
    SubstFunc (pf, pf', fill_token env _from _to e)
  | SubstGal (x, e, e') ->
    SubstGal (x, fill_token env _from _to e, fill_token env _from _to e')
  | Process gs -> Process (List.map ~f:(fill_token env _from _to) gs)
  | Token x when equal_string x _from -> _to
  | Token x -> Token x

let subst_vars env _from _to =
  map_galaxy_expr env ~f:(Lsc_ast.subst_all_vars [(_from, _to)])

let subst_funcs env _from _to =
  map_galaxy_expr env ~f:(Lsc_ast.subst_all_funcs [(_from, _to)])

let rec eval_galaxy_expr (env : env) : galaxy_expr -> galaxy = function
  | Raw g -> g
  | Token _ -> Const []
  | Access (e, x) ->
    begin match eval_galaxy_expr env e with
    | Const _ -> failwith "Can't access field of a constellation."
    | Galaxy g ->
      List.Assoc.find_exn ~equal:equal_string g x
      |> eval_galaxy_expr env
    end
  | Id x ->
    begin try
      get_obj env x |> eval_galaxy_expr env
    with Sexplib0__Sexp.Not_found_s _ ->
      failwith ("Error: undefined identifier " ^ x ^ ".");
    end
  | Union (e, e') ->
    let mcs1 = eval_galaxy_expr env e  |> galaxy_to_constellation env in
    let mcs2 = eval_galaxy_expr env e' |> galaxy_to_constellation env in
    Const (mcs1 @ mcs2)
  | Exec e  ->
    Const (eval_galaxy_expr env e
    |> galaxy_to_constellation env
    |> exec ~showtrace:!showtrace ~showsteps:!showsteps
    |> (if !cleaner then concealing else Fn.id)
    |> unmark_all)
  | Extend (pf, e) ->
    Const (eval_galaxy_expr env e
    |> galaxy_to_constellation env
    |> List.map ~f:(Lsc_ast.map_mstar ~f:(fun r -> Lsc_ast.gfunc pf [r])))
  | Reduce (pf, e) ->
    Const (eval_galaxy_expr env e
    |> galaxy_to_constellation env
    |> List.map ~f:(Lsc_ast.map_mstar ~f:(fun r -> match r with
      | Lsc_ast.StellarRays.Func (pf', ts)
        when Lsc_ast.StellarSig.equal_idfunc (snd pf) (snd pf')
        && List.length ts = 1 -> List.hd_exn ts
      | _ -> r)))
  | Focus e ->
    Const (eval_galaxy_expr env e
    |> galaxy_to_constellation env
    |> remove_mark_all |> focus)
  | Process [] -> failwith "ExprError: empty stellar sequence."
  | Process (h::t) ->
    let init = eval_galaxy_expr env h
      |> galaxy_to_constellation env
      |> remove_mark_all
      |> focus in
    Const (List.fold_left t ~init:init ~f:(fun acc x ->
      match x with
      | Clean -> acc
        |> remove_mark_all
        |> concealing
        |> focus
      | _ ->
        let origin = acc |> remove_mark_all |> focus in
        eval_galaxy_expr env (Exec (Union (x, Raw (Const origin))))
        |> galaxy_to_constellation env
    ))
  | Clean -> failwith "'Clean' special cannot occur outside stellar sequences."
  | SubstVar (x, r, e) ->
    subst_vars env (x, None) r e
    |> eval_galaxy_expr env
  | SubstFunc (pf1, pf2, e) ->
    subst_funcs env pf1 pf2 e
    |> eval_galaxy_expr env
  | SubstGal (x, _to, e) ->
    fill_token env x _to e
    |> eval_galaxy_expr env

and galaxy_to_constellation env = function
  | Const mcs -> mcs
  | Galaxy g -> List.fold_left g ~init:[] ~f:(fun acc (_, v) ->
    galaxy_to_constellation env (eval_galaxy_expr env v) @ acc)

let equal_galaxy env g g' =
  let mcs  = galaxy_to_constellation env g  in
  let mcs' = galaxy_to_constellation env g' in
  Lsc_ast.equal_mconstellation mcs mcs'

let typecheck env x t (ck : ident option) : unit =
  let echecker = match ck with
    | None -> Union (Token "tested", Token "test")
    | Some xck -> get_obj env xck
  in
  let gtests = match get_obj env t |> eval_galaxy_expr env with
    | Const mcs -> [("_", Raw (Const mcs))]
    | Galaxy gtests -> gtests
  in
  let gchecker =
    match echecker |> eval_galaxy_expr env with
    | Const _ -> failwith "Ill-formed checker."
    | Galaxy g -> g
  in
  let testing = List.map gtests ~f:(fun (_, test) ->
    Exec (SubstGal ("tested", get_obj env x,
        SubstGal ("test", test,
            List.Assoc.find_exn ~equal:equal_string gchecker "interaction")))
    |> eval_galaxy_expr env
  ) in
  let expect =
    List.Assoc.find_exn ~equal:equal_string gchecker "expect"
    |> eval_galaxy_expr env
  in
  if List.exists testing ~f:(fun r -> not (equal_galaxy env r expect)) then
    failwith ("TypeError: " ^ x ^ " not of type " ^ t ^ ".")

let eval_decl env : declaration -> env = function
  | Def (x, e) ->
    let env = { objs = add_obj env x e; types = env.types } in
    begin match List.Assoc.find ~equal:equal_string env.types x with
    | Some (t, ck) -> (typecheck env x t ck; env)
    | None -> env
    end
  | ShowGalaxy e ->
    eval_galaxy_expr env e
    |> galaxy_to_constellation env
    |> List.map ~f:remove_mark
    |> string_of_constellation
    |> Stdlib.print_string;
    Stdlib.print_newline ();
    env
 | PrintGalaxy e ->
    eval_galaxy_expr env (Exec e)
    |> galaxy_to_constellation env
    |> List.map ~f:remove_mark
    |> string_of_constellation
    |> Stdlib.print_string;
    Stdlib.print_newline ();
    env
  | SetOption (id, b) ->
    begin
      if (equal_string id "show-steps") then (showsteps := b)
      else if (equal_string id "show-trace") then (showtrace := b)
      else if (equal_string id "cleaner") then (cleaner := b)
      else failwith ("OptionEror: unrecognized option '" ^ id ^ "'.")
    end;
    env
  | TypeDef (x, t, ck) ->
    { objs = env.objs; types = add_type env x (t, ck) }

let eval_program p =
  let empty_env = { objs = []; types = [] } in
  List.fold_left
  ~f:(fun acc x -> eval_decl acc x)
  ~init:empty_env p
