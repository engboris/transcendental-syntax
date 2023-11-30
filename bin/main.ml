open Base
open Lsc.Stellar
open Lsc.Parser
open Out_channel

let usage_msg = "exec [-noloops] [-steps] <filename>"
let withloops = ref true
let showsteps = ref false
let input_file = ref ""

let anon_fun filename = input_file := filename

let speclist =
  [
    ("-noloops", Stdlib.Arg.Clear withloops, "Forbid equations X=X which yields trivial loops");
    ("-showsteps", Stdlib.Arg.Set showsteps, "Interactively show each steps")
  ]

let _ =
  Stdlib.Arg.parse speclist anon_fun usage_msg;
  let lexbuf = Lexing.from_channel (Stdlib.open_in !input_file) in
  let cs = spacec Lsc.Lexer.read lexbuf in
  (if !showsteps then output_string stdout "Press any button to move to the next step.\n");
  let result = exec ~withloops:!withloops ~showsteps:!showsteps cs in
  if not !showsteps then Stdlib.print_endline (string_of_constellation result)
