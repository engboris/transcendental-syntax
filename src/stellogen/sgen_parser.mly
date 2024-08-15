%{
open Sgen_ast
%}

%token LBRACE RBRACE
%token <string> STRING
%token PRINT
%token EXEC
%token DEF END

%right PLUS

%start <Sgen_ast.program> program

%%

program:
| EOF { [] }
| ds=declaration+; EOF { ds }

declaration:
| DEF; x=SYM; e=stellar_expr; END? { Def (x, e) }
| DEF; x=SYM; cs=marked_constellation; END { Def (x, Raw cs) }
| c=command { Command c }

command:
| PRINT; e=stellar_expr; END? { PrintStellar e }
| PRINT; cs=marked_constellation; END { PrintStellar (Raw cs) }
| PRINT; s=STRING; END? { PrintMessage s }

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

