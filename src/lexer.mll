{
  open Parser
}

let var_id   = ['A'-'Z'] ['A'-'Z' '0'-'9' '_' '-']* '\''*
let func_id  = ['a'-'z' '0'-'9'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '-']* '\''* '?'?
let space    = [' ' '\t']+
let newline  = '\r' | '\n' | "\r\n"

rule read = parse
  | var_id   { VAR (Lexing.lexeme lexbuf) }
  | func_id  { SYM (Lexing.lexeme lexbuf) }
  | '\''     { comment lexbuf }
  | "'''"    { comments lexbuf }
  | '_'      { PLACEHOLDER }
  | '['      { LBRACK }
  | ']'      { RBRACK }
  | '('      { LPAR }
  | ')'      { RPAR }
  | ','      { COMMA }
  | '@'      { AT }
  | '+'      { PLUS }
  | '-'      { MINUS }
  | '$'      { EMPTY_SYM }
  | ':'      { CONS }
  | ';'      { SEMICOLON }
  | space    { read lexbuf }
  | newline  { read lexbuf }
  | eof      { EOF }

and comment = parse
  | (newline|eof)  { read lexbuf }
  | _              { comment lexbuf }

and comments = parse
  | "'''"    { read lexbuf }
  | _        { comments lexbuf }
