open Base
open Lsc.Lsc_ast
open Lsc.Lsc_parser
open Lsc.Lsc_lexer

let welcome () =
  Stdlib.print_string "Commands :--------------------------------------\n";
  Stdlib.print_string "<constellation>\t\tMake a new constellation interacts
  \t\t\twith the previous interaction space\n\t\t\t({} at beginning)\n";
  Stdlib.print_string "exit|e|q\t\tquit the program\n";
  Stdlib.print_string "clear|c\t\t\tclear interaction space\n";
  Stdlib.print_string "delete|del|d\t\tdelete a star at some index\n";
  Stdlib.print_string "add|a\t\t\tadd stars\n";
  Stdlib.print_string "------------------------------------------------\n"

let prompt mode =
  Stdlib.print_string (mode ^ " >> ");
  Stdlib.read_line ()

let rec delete cs =
  let input = prompt "Delete star of index" in
  try
    let n = Int.of_string input in
    List.filteri ~f:(fun i _ -> not (equal_int i n)) cs
  with Failure _ ->
    Stdlib.print_string "This is not a positive integer. Please retry.\n";
    delete cs

let rec add cs =
  let input = prompt "Add stars" in
  try
    let lexbuf = Lexing.from_string input in
    let mcs = marked_constellation read lexbuf in
    cs @ (List.map ~f:remove_mark mcs)
  with _ ->
    Stdlib.print_string "Error. Please retry.\n";
    add cs

let rec loop (cs : constellation) =
  cs |> string_of_constellation |> Stdlib.print_string;
  Stdlib.print_newline ();
  let input = prompt "Send" in
  if (List.mem ~equal:equal_string ["exit"; "e"; "q"] input) then
    Stdlib.exit 0
  else if (List.mem ~equal:equal_string ["clear"; "c"] input) then
    loop []
  else if (List.mem ~equal:equal_string ["delete"; "del"; "d"] input) then
    loop (delete cs)
  else if (List.mem ~equal:equal_string ["add"; "a"] input) then
    loop (add cs)
  else
    begin
      let base = List.map ~f:(fun s -> Marked s) cs in
      let lexbuf = Lexing.from_string input in
      try
        let mcs = marked_constellation read lexbuf in
        let cs = extract_intspace (base @ mcs) in
        let result =
          exec ~unfincomp:true
               ~withloops:false
               ~showtrace:false
               ~selfint:false
               ~showsteps:false cs in
        loop result
      with _ ->
        Stdlib.print_string "Error. Please retry.\n";
        loop cs
    end

let _ =
  welcome ();
  loop [];
