%{
open Sgen_ast
%}

%token LBRACE RBRACE
%token SHOW PRINT
%token SPEC
%token RARROW
%token TEST
%token WITH
%token EQ
%token DOT
%token END

%start <Sgen_ast.program> program

%%

program:
| EOL*; EOF { [] }
| EOL*; d=declaration; EOL+; p=program { d::p }
| EOL*; d=declaration; EOF { [d] }

declaration:
| e=stellar_expr
  { RawComp e }
| x=SYM; EQ; e=stellar_expr
  { Def (x, e) }
| SPEC; x=SYM; EQ; EOL*; tests=test_definition+; END
  { Spec (x, tests) }
| TEST; x=SYM; CONS; t=SYM; WITH; pred=SYM
  { Typecheck (x, t, pred) }
| SHOW; e=stellar_expr
  { ShowStellar e }
| PRINT; e=stellar_expr
  { PrintStellar e }

test_definition:
| name=SYM; RARROW; e=stellar_expr; EOL+ { (name, e) }

assoc:
| pf1=symbol; RARROW; pf2=symbol { AssocFunc (pf1, pf2) }
| x=VAR; RARROW; r=ray { AssocVar ((x, None), r) }

stellar_expr:
| DOLLAR; e=stellar_expr
  { Kill e }
| e=stellar_expr;
  LBRACK; sub=separated_list(COMMA, assoc) RBRACK
  { Subst (sub, e) }
| LPAR; e=stellar_expr; RPAR
  { e }
| LBRACE; EOL*; RBRACE
  { Raw [] }
| LBRACE; EOL*; cs=marked_constellation; EOL* RBRACE
  { Raw cs }
| x=SYM
  { Id x }
| spec=SYM; DOT; test=SYM
  { TestAccess (spec, test) }
| e1=stellar_expr; e2=stellar_expr
  { Union (e1, e2) }
