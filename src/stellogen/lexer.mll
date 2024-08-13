{
  open Parser
}

let ident    = ['a'-'z' '0'-'9'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '-']* '\''* '?'?
let space    = [' ' '\t']+
let newline  = '\r' | '\n' | "\r\n"

rule read = parse
  | ident    { ID (Lexing.lexeme lexbuf) }
  | '\''     { comment lexbuf }
  | "'''"    { comments lexbuf }
  | '{'      { LBRACE }
  | '}'      { RBRACE }
  | "print"  { PRINT }
  | "int"    { INT }
  | "def"    { DEF }
  | "end"    { END }
  | space    { read lexbuf }
  | newline  { read lexbuf }
  | eof      { EOF }

and comment = parse
  | (newline|eof)  { read lexbuf }
  | _              { comment lexbuf }

and comments = parse
  | "'''"    { read lexbuf }
  | _        { comments lexbuf }
