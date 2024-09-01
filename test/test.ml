open Alcotest
open Base
open Lsc.Lsc_ast
open Lsc.Lsc_parser
open Lsc.Lsc_lexer

let test filename expected () =
  let lexbuf = Lexing.from_channel (Stdlib.open_in filename) in
  let mcs = marked_constellation read lexbuf in
  let cs = extract_intspace mcs in
  let result =
    exec ~withloops:false
         ~showtrace:false
         ~selfint:false
         ~showsteps:false cs
         |> concealing
         |> string_of_constellation in
  check string "same string" result expected

let example filename = "../examples/" ^ filename

let suite =
  [ "Automata", `Quick, test (example "automata/nfsa_ending00.stellar") "accept;"
  ; "Prolog", `Quick, test (example "logicprogramming/prolog.stellar") "s(s(s(s(0))));"
  ; "MLL (cut-elim)", `Quick, test (example "mll/cut.stellar") "6(X33) 3(X33);"
  ]

let () =
  Alcotest.run "Stellar Resolution" [ "Basic tests", suite ]
