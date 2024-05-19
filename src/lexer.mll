{
  open Parser
}

let var_id   = ['A'-'Z'] ['A'-'Z' '0'-'9']*
let func_id  = ['a'-'z' '0'-'9' '_']+
let space    = [' ' '\t']+
let newline  = '\r' | '\n' | "\r\n"

rule read = parse
	| var_id   { VAR (Lexing.lexeme lexbuf) }
	| func_id  { SYM (Lexing.lexeme lexbuf) }
	| '['      { LEFT_BRACK }
	| ']'      { RIGHT_BRACK }
	| '('      { LEFT_PAR }
	| ')'      { RIGHT_PAR }
	| ','      { COMMA }
	| '@'      { AT }
	| '+'      { PLUS }
	| '-'      { MINUS }
	| ':'      { CONS }
	| ';'      { SEMICOLON }
	| space    { read lexbuf }
	| newline  { read lexbuf }
	| eof      { EOF }
