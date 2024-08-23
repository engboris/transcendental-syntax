{
  open Sgen_parser
  exception SyntaxError of string
}

let ident    = ['a'-'z' '0'-'9'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '-']* '\''* '?'?
let var_id   = ['A'-'Z'] ['A'-'Z' '0'-'9' '_' '-']* '\''*
let space    = [' ' '\t']+
let newline  = '\r' | '\n' | "\r\n"

rule read = parse
  (* Stellogen *)
  | '{'      { LBRACE }
  | '}'      { RBRACE }
  | "def"    { DEF }
  | "end"    { END }
  | "exec"   { EXEC }
  | "show"   { SHOW }
  | "spec"   { SPEC }
  | "test"   { TEST }
  | "with"   { WITH }
  | "->"     { RARROW }
  | '"'      { read_string (Buffer.create 255) lexbuf }
  (* Stellar resolution *)
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
  | var_id   { VAR (Lexing.lexeme lexbuf) }
  | ident    { SYM (Lexing.lexeme lexbuf) }
  (* Common *)
  | '\''     { comment lexbuf }
  | "'''"    { comments lexbuf }
  | space    { read lexbuf }
  | newline  { read lexbuf }
  | eof      { EOF }
  | _        {
    raise (SyntaxError
      ("Unexpected character '" ^
      (Lexing.lexeme lexbuf) ^
      "' during lexing"))
  }

and read_string buf =
  parse
  | '"'       { STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | [^ '"' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_string buf lexbuf
    }
  | _ {
    raise (SyntaxError
      ("Illegal string character: " ^ Lexing.lexeme lexbuf))
    }
  | eof { raise (SyntaxError ("String is not terminated")) }

and comment = parse
  | (newline|eof)  { read lexbuf }
  | _              { comment lexbuf }

and comments = parse
  | "'''"    { read lexbuf }
  | _        { comments lexbuf }
