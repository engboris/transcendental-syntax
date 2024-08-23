%{
open Sgen_ast
%}

%token LBRACE RBRACE
%token SHOW
%token EXEC
%token SPEC
%token RARROW
%token TEST
%token WITH
%token DEF
%token END

%start <Sgen_ast.program> program

%%

program:
| EOF { [] }
| ds=declaration+; EOF { ds }

declaration:
| DEF; x=SYM; e=stellar_expr; END? { Def (x, e) }
| DEF; x=SYM; cs=marked_constellation; END { Def (x, Raw cs) }
| SPEC; x=SYM;
  tests=test_definition+;
  END
  { Spec (x, tests) }
| TEST; x=SYM; CONS; t=SYM; WITH; pred=SYM
  { Typecheck (x, t, pred) }
| SHOW; e=stellar_expr; END? { ShowStellar e }
| SHOW; cs=marked_constellation; END { ShowStellar (Raw cs) }

test_definition:
| name=SYM; RARROW; e=stellar_expr { (name, e) }

stellar_expr:
| LPAR; e=stellar_expr; RPAR
  { e }
| LBRACE; RBRACE
  { Raw [] }
| LBRACE; cs=marked_constellation; RBRACE
  { Raw cs }
| x=SYM
  { Id x }
| EXEC; e=stellar_expr
  { Exec e }
| e1=stellar_expr; AT; e2=stellar_expr
  { Union (e1, e2) }
| spec=SYM; LBRACK; test=SYM; RBRACK
  { TestAccess (spec, test) }

