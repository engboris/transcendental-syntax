open Base
open Stellogen.Sgen_ast
open Stellogen.Sgen_parser
open Stellogen.Sgen_lexer

let usage_msg = "sgen <filename>"
let input_file = ref ""

let anon_fun filename = input_file := filename

let speclist = []

let _ =
  Stdlib.Arg.parse speclist anon_fun usage_msg;
  let lexbuf = Lexing.from_channel (Stdlib.open_in !input_file) in
  let p = program read lexbuf in
  eval_program p
