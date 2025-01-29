open Base
open Stellogen.Sgen_ast
open Stellogen.Sgen_parser
open Stellogen.Sgen_lexer
open Lexing

let usage_msg = "sgen <filename>"

let input_file = ref ""

let anon_fun filename = input_file := filename

let speclist = []

let parse_with_error lexbuf =
  try program read lexbuf
  with SyntaxError msg ->
    Stdlib.Printf.fprintf Stdlib.stderr "%a: %s\n" print_position lexbuf msg;
    Stdlib.exit (-1)

let () =
  Stdlib.Arg.parse speclist anon_fun usage_msg;
  let lexbuf = Lexing.from_channel (Stdlib.open_in !input_file) in
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = !input_file };
  let p = parse_with_error lexbuf in
  let _ = eval_program p in
  ()
