%{
open Ast
%}

%token LBRACE RBRACE
%token <string> ID
%token PRINT
%token INT
%token DEF END
%token EOF

%start <Ast.program> program

%%

program:
| EOF { [] }
| ds=nonempty_list(declaration); EOF { ds }

declaration:
| DEF; x=ID; END { Def (x, []) }
| e=stellar_expr { Expr e }

stellar_expr:
| LBRACE; RBRACE { Raw [] }
| x=ID           { Id x }
| INT            { Int [] }
