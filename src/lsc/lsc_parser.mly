%{
open Lsc_ast
%}

%token COMMA
%token LBRACK RBRACK
%token LPAR RPAR
%token <string> VAR
%token <string> SYM
%token PLUS MINUS
%token CONS
%token AT
%token SEMICOLON
%token PLACEHOLDER

%right CONS

%start <marked_constellation> constellation_file
%start <marked_constellation> marked_constellation

%%

constellation_file:
| EOF { [] }
| cs=marked_constellation; EOF { cs }

marked_constellation:
| cs=separated_nonempty_list(pair(SEMICOLON, EOL*), star); SEMICOLON?
  { cs }

%public star:
| AT; s=star_content; EOL* { Marked s }
| s=star_content; EOL* { Unmarked s }

star_content:
| LBRACK; RBRACK { [] }
| rs=separated_nonempty_list(pair(COMMA?, EOL*), ray) { rs }

%public symbol:
| pf=pol_symbol   { pf }
| pf=unpol_symbol { pf }

%public pol_symbol:
| PLUS; SHARP; f = SYM { noisy (Pos, f) }
| PLUS; SHARP; PRINT { noisy (Pos, "print") }
| PLUS; f = SYM { muted (Pos, f) }
| MINUS; SHARP; f = SYM { noisy (Neg, f) }
| MINUS; SHARP; PRINT { noisy (Neg, "print") }
| MINUS; f = SYM { muted (Neg, f) }

%public unpol_symbol:
| f=SYM { muted (Null, f) }

%public %inline args:
| LPAR; ts = separated_nonempty_list(COMMA?, ray); RPAR { ts }

%public ray:
| PLACEHOLDER { to_var ("_"^(fresh_placeholder ())) }
| x = VAR { to_var x }
| e = func_expr { e }

func_expr:
| e=cons_expr { e }
| pf=symbol; ts=args? { to_func (pf, Option.to_list ts |> List.concat) }

cons_expr:
| r1 = ray; CONS; r2 = ray
| LPAR; r1 = ray; CONS; r2 = ray; RPAR
  { to_func (noisy (Null, ":"), [r1; r2]) }
| LPAR; e = cons_expr; RPAR; CONS; r = ray
	{ to_func (muted (Null, ":"), [e; r]) }
