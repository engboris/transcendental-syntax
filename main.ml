open Stellar
open Parser
open Tools

(* ---------------------------------------
   Prompt
   --------------------------------------- *)

let welcome () = print_endline "Use 'help' for the list of commands."

let tab = repeat_string "\t"

let line = repeat_string "-"

let commands_list () =
	print_endline ("Command" ^ tab 4 ^ "Description (shortcut)");
	print_endline (line 70);
	print_endline ("exit" ^ tab 4 ^ "Exits the program");
	print_endline ("exec -f <filename>" ^ tab 2 ^ "Executes the constellation defined in <filename>");
	print_endline ("exec <intspace>" ^ tab 3 ^ "Executes the interaction space <intspace>");
	print_endline (
		"intmode" ^
		tab 4 ^
		"Enables interactive mode with the empty constellation as initial constellation."
	);
	print_endline (
		"intmode <constellation>" ^
		tab 2 ^
		"Enables interactive mode with <constellation> as initial constellation"
	);
	print_endline (
		"intmode -f <filename>" ^
		tab 2 ^
		"Enables interactive mode with the constellation defined in <filename> as initial constellation"
	);
	print_endline (
		"disable-loops" ^
		tab 2 ^
		"Forbid equations X=X which yields trivial loops"
	);
	print_endline (
		"enable-loops" ^
		tab 2 ^
		"Allow equations X=X which yields trivial loops (default setting)"
	)

let prompt () = print_string "> "

let intmode_prompt cs =
	print_endline ">>>>>>>>>> Interactive mode";
	print_endline "Type constellations and they will interact your initial constellation ('exit' to exit interactive mode).";
	print_endline (string_of_constellation cs)
	
let rec intmode ?(withloops=true) cs =
	prompt ();
	let input = read_line () in
	if input = "exit" then
		print_endline "<<<<<<<<<< Exit interactive mode"
	else
		(try
			let cs' = constc Lexer.read (Lexing.from_string input) in
			let result = intexec ~withloops (cs, cs') in
			print_endline (string_of_constellation result);
			intmode result
		with _ ->
			print_endline "Syntax error. Please try again.";
			intmode cs)

let last_command : string option ref = ref None

(* ---------------------------------------
   Main function
   --------------------------------------- *)

let _ =
	let withloops = ref true in
	welcome ();
	while true do
		prompt ();
		let input = read_line () in 
		begin match String.split_on_char ' ' input with
		| ["exit"] -> exit 0
		| ["disable-loops"] ->
			print_endline "Loops disabled."; withloops := false
		| ["enable-loops"] ->
			print_endline "Loops enabled."; withloops := true
		| ["help"] -> commands_list ()
		| ["exec"; "-f"; filename] ->
			begin try
				let lexbuf = Lexing.from_channel (open_in filename) in
				let cs = spacec Lexer.read lexbuf in
				let result = intexec ~withloops:!withloops cs in
				print_endline (string_of_constellation result)
			with Sys_error f -> print_endline f
			end
		| "exec"::intspace ->
			let lexbuf = Lexing.from_string (String.concat " " intspace) in
			(try 
				let cs = spacec Lexer.read lexbuf in
				let result = intexec ~withloops:!withloops cs in
				print_endline (string_of_constellation result)
			with _ -> print_endline "Syntax error. Please try again.")
		| ["intmode"; "-f"; filename] ->
			(try
				let lexbuf = Lexing.from_channel (open_in filename) in
				let cs = constc Lexer.read lexbuf in
				intmode_prompt cs;
				intmode cs
			with Sys_error f -> print_endline f)
		| ["intmode"] ->
			intmode_prompt [];
			intmode []
		| "intmode"::intspace ->
			let lexbuf = Lexing.from_string (String.concat " " intspace) in
			let cs = constc Lexer.read lexbuf in
			intmode_prompt cs;
			intmode cs
		| _ ->
			print_endline "Invalid command. Please type 'help' for the list of commands."
		end
	done