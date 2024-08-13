open Base
open Lsc.Ast

type ident = string

type stellar_expr =
  | Raw of constellation
  | Id of ident
  | Int of constellation

type command =
  | PrintStellar of stellar_expr
  | PrintMessage of string

type declaration =
  | Def of ident * constellation
  | Expr of stellar_expr
  | Command of command

type program = declaration list
