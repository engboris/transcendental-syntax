open Stellar
open Parser

let usage_msg = "exec [-noloops] <filename>"
let withloops = ref true
let input_file = ref ""

let anon_fun filename = input_file := filename

let speclist =
  [
    ("-noloops", Arg.Clear withloops, "Forbid equations X=X which yields trivial loops")
  ]

let _ =
	Arg.parse speclist anon_fun usage_msg;
	let lexbuf = Lexing.from_channel (open_in !input_file) in
	let cs = spacec Lexer.read lexbuf in
	let result = exec ~withloops:!withloops cs in
	print_endline (string_of_constellation result)