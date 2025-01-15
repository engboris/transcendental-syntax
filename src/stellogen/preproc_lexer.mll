{
  open Sgen_parser
  exception SyntaxError of string
}

let alpha    = ['a'-'z' 'A'-'Z']
let num      = ['0'-'9']
let alphanum = alpha | num
let filename = alphanum (alphanum | [ '.' '_'])*
let space    = [' ' '\t']+
let newline  = '\r' | '\n' | "\r\n"

let include_decl = "include" space filename

rule read = parse
  | include_decl { INCLUDE (Lexing.lexeme lexbuf) }
  | '\''         { comment lexbuf }
  | "'''"        { comments lexbuf }
  | eof          { EOF }
  | _ as x       { CHAR x }

and comment = parse
  | eof         { EOF }
  | _           { comment lexbuf }

and comments = parse
  | "'''"       { read lexbuf }
  | _           { comments lexbuf }
