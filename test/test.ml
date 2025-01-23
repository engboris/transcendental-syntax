open Base
open Stellogen.Sgen_ast
open Stellogen.Sgen_parser
open Stellogen.Sgen_lexer

let test filename () =
  let lexbuf = Lexing.from_channel (Stdlib.open_in filename) in
  let p = program read lexbuf in
  let _ = eval_program p in
  ()

let suite =
  let suite x = "./testsuite/" ^ x in
  let example x = "../examples/" ^ x in
  [ ("Syntax of Stellogen", `Quick, test (example "syntax.sg"))
  ; ("Automata", `Quick, test (suite "automata.sg"))
  ; ("Prolog", `Quick, test (suite "prolog.sg"))
  ]

let () = Alcotest.run "Stellogen Test Suite" [ ("Stellogen test suite", suite) ]
