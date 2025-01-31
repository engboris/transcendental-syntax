open Base
open Stellogen.Sgen_ast
open Stellogen.Sgen_parser
open Stellogen.Sgen_lexer

let test filename () =
  let lexbuf = Lexing.from_channel (Stdlib.open_in filename) in
  let p = program read lexbuf in
  let _ = eval_program p in
  ()

let syntax =
  let file x = "./syntax/" ^ x in
  [ ("Definitions", `Quick, test (file "definitions.sg")) ]

let behavior =
  let file x = "./behavior/" ^ x in
  [ ("Automata", `Quick, test (file "automata.sg"))
  ; ("Prolog", `Quick, test (file "prolog.sg"))
  ]

let () =
  Alcotest.run "Stellogen Test Suite"
    [ ("Stellogen syntax test suite", syntax)
    ; ("Stellogen behavior test suite", behavior)
    ]
