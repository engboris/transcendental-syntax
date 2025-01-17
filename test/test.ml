open Base
open Stellogen.Sgen_ast
open Stellogen.Sgen_parser
open Stellogen.Sgen_lexer

let test filename () =
  let lexbuf = Lexing.from_channel (Stdlib.open_in filename) in
  let p = program read lexbuf in
  let _ = eval_program p in
  ()

let example filename = "./testsuite/" ^ filename

let suite =
  [ ("Automata", `Quick, test (example "automata.sg"))
  ; ("Prolog", `Quick, test (example "prolog.sg"))
  ]

let () = Alcotest.run "Stellogen Test Suite" [ ("Basic tests", suite) ]
