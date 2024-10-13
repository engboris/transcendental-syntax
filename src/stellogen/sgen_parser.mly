%{
open Sgen_ast
%}

%token LBRACE RBRACE
%token SHOW PRINT
%token SPEC
%token CLEAN
%token SEQ
%token SET UNSET
%token DRARROW DARROW
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
| SET; x=SYM
  { SetOption (x, true) }
| UNSET; x=SYM
  { SetOption (x, false) }

test_definition:
| name=SYM; DRARROW; e=stellar_expr; EOL+ { (name, e) }

assoc:
| pf1=symbol; DRARROW; pf2=symbol { AssocFunc (pf1, pf2) }
| x=VAR; DRARROW; r=ray { AssocVar ((x, None), r) }

stellar_expr:
| pf=symbol; CONS; e=stellar_expr
  { Extend (pf, e) }
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
| SEQ; EOL*; h=stellar_expr; EOL*; t=stellar_item*; END
  { Seq (h::t) }
| CLEAN
  { Clean }

stellar_item:
| DARROW; e=stellar_expr; EOL* { e }
