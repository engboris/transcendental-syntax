open Base
(* open Stellogen.Ast *)
open Stellogen.Parser
open Stellogen.Lexer

let usage_msg = "sgen <filename>"
let input_file = ref ""

let anon_fun filename = input_file := filename

let speclist = []

let _ =
  Stdlib.Arg.parse speclist anon_fun usage_msg;
  let lexbuf = Lexing.from_channel (Stdlib.open_in !input_file) in
  let prog = program read lexbuf in
  ()
