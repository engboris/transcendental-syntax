%{
open Sgen_ast
%}

%token LBRACE RBRACE
%token <string> ID
%token <string >STRING
%token PRINT
%token INT
%token DEF END

%start <Sgen_ast.program> program

%%

program:
| EOF { [] }
| ds=nonempty_list(declaration); EOF { ds }

declaration:
| DEF; x=ID; e=stellar_expr; END { Def (x, e) }
| DEF; x=ID; cs=marked_constellation; END { Def (x, Raw cs) }
| c=command { Command c }

command:
| PRINT; e=stellar_expr { PrintStellar e }
| PRINT; cs=marked_constellation; END { PrintStellar (Raw cs) }
| PRINT; s=STRING { PrintMessage s }

stellar_expr:
| LBRACE; RBRACE
  { Raw [] }
| LBRACE; cs=marked_constellation; RBRACE
  { Raw cs }
| x=ID
  { Id x }
| INT; e1=stellar_expr; e2=stellar_expr
  { Int (e1, e2) }

