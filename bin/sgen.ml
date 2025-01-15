open Base
open Stellogen.Sgen_ast
open Stellogen.Sgen_parser

let usage_msg = "sgen <filename>"
let input_file = ref ""

let anon_fun filename = input_file := filename

let speclist = []

let () =
  Stdlib.Arg.parse speclist anon_fun usage_msg;
  let lexbuf = Lexing.from_channel (Stdlib.open_in !input_file) in
  let preprocess = preprocess Stellogen.Preproc_lexer.read lexbuf in
  Out_channel.output_string Out_channel.stdout preprocess;
  Out_channel.output_string Out_channel.stdout "\n";
  Out_channel.flush Out_channel.stdout;
  let lexbuf = Lexing.from_string preprocess in
  let prog = program Stellogen.Sgen_lexer.read lexbuf in
  let _ = eval_program prog in ()
