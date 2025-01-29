(* FIXME *)

open Alcotest
open Base
open Lsc.Lsc_ast
open Lsc.Lsc_parser
open Lsc.Lsc_lexer

let test filename expected () =
  let lexbuf = Lexing.from_channel (Stdlib.open_in filename) in
  let mcs = constellation_file read lexbuf in
  let result =
    exec ~showtrace:false
         ~showsteps:false mcs
         |> kill
         |> string_of_constellation in
  check string "same string" result expected

let example filename = "../examples/" ^ filename

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
