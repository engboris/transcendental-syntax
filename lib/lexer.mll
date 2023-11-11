{
  open Parser
  exception Eof
}

let var_id   = ['A'-'Z'] ['0'-'9']*
let func_id  = ['a'-'z' '0'-'9']+
let space    = [' ' '\t']+
let newline  = '\r' | '\n' | "\r\n"

rule read = parse
	| var_id   { VAR (Lexing.lexeme lexbuf) }
	| func_id  { SYM (Lexing.lexeme lexbuf) }
	| '('      { LEFT_PAR }
	| ')'      { RIGHT_PAR }
	| ','      { COMMA }
	| '['      { LEFT_BRACK }
	| ']'      { RIGHT_BRACK }
	| '{'      { LEFT_BRACE }
	| '}'      { RIGHT_BRACE }
	| '+'      { PLUS }
	| '-'      { MINUS }
	| "|-"     { VDASH }
	| '.'      { DOT }
	| space    { read lexbuf }
	| newline  { read lexbuf }
	| eof      { exit 0 }