open Base
open Lsc.Stellar
open Lsc.Parser
open Out_channel

let usage_msg = "exec [-unfinished-computation] [-noloops] [-showsteps] <filename>"
let withloops = ref true
let showsteps = ref false
let unfincomp = ref false
let input_file = ref ""

let anon_fun filename = input_file := filename

let speclist =
  [
    ("-noloops",
     Stdlib.Arg.Clear withloops,
     "Forbid equations X=X which yield trivial loops (they are allowed by
      default).");
    ("-unfinished-computation",
     Stdlib.Arg.Set unfincomp,
      "Show stars containing polarities which are left after execution
      (they correspond to unfinished computation and are omitted by default).");
    ("-showsteps",
     Stdlib.Arg.Set showsteps,
     "Interactively show each steps of computation.")
  ]

let _ =
  Stdlib.Arg.parse speclist anon_fun usage_msg;
  let lexbuf = Lexing.from_channel (Stdlib.open_in !input_file) in
  let mcs = marked_constellation Lsc.Lexer.read lexbuf in
  let cs = extract_intspace mcs in
  (if !showsteps
  then output_string stdout "Press any key to move to the next step.\n");
  let result =
    exec ~unfincomp:!unfincomp
         ~withloops:!withloops
         ~showsteps:!showsteps cs in
  if not !showsteps then Stdlib.print_endline (string_of_constellation result)
  else output_string stdout "No interaction left.\n"
