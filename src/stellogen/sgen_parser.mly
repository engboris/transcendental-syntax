%{
open Sgen_ast
%}

%token LBRACE RBRACE
%token SHOW PRINT
%token PROCESS
%token GALAXY
%token RARROW DRARROW
%token EQ
%token DOT
%token END

%start <Sgen_ast.program> program

%%

program:
| EOL*; EOF { [] }
| EOL*; d=declaration; EOL+; p=program { d::p }
| EOL*; d=declaration; EOF { [d] }

let declaration :=
  | ~=SYM; EOL*; EQ; EOL*; ~=galaxy_expr; <Def>
  | PLACEHOLDER; EOL*; EQ; EOL*;
    g=galaxy_expr;
    { Def ("_"^(fresh_placeholder ()), g) }
  | SHOW; EOL*; ~=galaxy_expr;            <Show>
  | SHOWEXEC; EOL*; ~=galaxy_expr;        <ShowExec>
  | ~=SYM; CONS; CONS; ~=SYM; EOL*;
    ~=checker_def; DOT;                   <TypeDef>
  | x=SYM; CONS; CONS; t=SYM; DOT;        { TypeDef (x, t, None) }

checker_def:
| LBRACK; x=SYM; RBRACK; { Some x }
| LBRACK; RBRACK;        { None }

galaxy_expr:
| gc=galaxy_content; DOT; { gc }
| gb=galaxy_block; END; { gb }
| gd=galaxy_def; END; { Raw (Galaxy gd) }

galaxy_content:
| LPAR; e=galaxy_content; RPAR        { e }
| LBRACE; EOL*; RBRACE                { Raw (Const []) }
| LBRACE; x=SYM; RBRACE               { Token x }
| cs=marked_constellation;            { Raw (Const cs) }
| x=SYM                               { Id x }
| e1=galaxy_content;
  e2=galaxy_content                   { Union (e1, e2) }
| g=galaxy_content; RARROW; x=SYM     { Access (g, x) }
| e=galaxy_content;
  LBRACK; DRARROW; pf=symbol; RBRACK; { Extend (pf, e) }
| e=galaxy_content;
  LBRACK; pf=symbol; DRARROW; RBRACK; { Reduce (pf, e) }
| AT; e=galaxy_content;               { Focus e }
| e=galaxy_content;
  LBRACK; x=VAR; DRARROW;
  r=ray; RBRACK;                      { SubstVar (x, r, e) }
| e=galaxy_content;
  LBRACK; pf1=symbol; DRARROW;
  pf2=symbol; RBRACK;                 { SubstFunc (pf1, pf2, e) }
| e=galaxy_content;
  LBRACK; _from=SYM; DRARROW;
  _to=galaxy_content; RBRACK;         { SubstGal (_from, _to, e) }

galaxy_def:
| GALAXY; EOL*; gis=galaxy_item+; { gis }

galaxy_item:
| x=SYM; CONS; EOL*; e=galaxy_content; DOT; EOL*; { (x, e) }
| x=SYM; CONS; EOL*; gb=galaxy_block; END; EOL*;  { (x, gb) }

%public let non_neutral_start_mcs :=
  | pf=pol_symbol; ts=args?; EOL*;
    rs=separated_list(pair(COMMA?, EOL*), ray);
    { [Unmarked ((to_func (pf, Option.to_list ts |> List.concat)) :: rs)] }
  | AT; pf=pol_symbol; ts=args?; EOL*;
    rs=separated_list(pair(COMMA?, EOL*), ray);
    { [Marked ((to_func (pf, Option.to_list ts |> List.concat)) :: rs)] }
  | nmcs=non_neutral_start_mcs; EOL*; SEMICOLON; EOL*;
    mcs=marked_constellation;
    { nmcs @ mcs }

%inline neutral_start_mcs:
  | pf=unpol_symbol; ts=args?;
    { [Unmarked [to_func (pf, Option.to_list ts |> List.concat)]] }
  | pf=unpol_symbol; ts=args?; EOL*;
    rs=separated_nonempty_list(pair(COMMA?, EOL*), ray);
    { [Unmarked ((to_func (pf, Option.to_list ts |> List.concat)) :: rs)] }
  | pf=unpol_symbol; ts=args?; EOL*;
    rs=separated_list(pair(COMMA?, EOL*), ray); EOL*;
    SEMICOLON; EOL*;
    cs=separated_nonempty_list(pair(SEMICOLON, EOL*), star); SEMICOLON?;
    { (Unmarked ((to_func (pf, Option.to_list ts |> List.concat)) :: rs)) :: cs }

let raw_constellation :=
  | LBRACE; EOL*; ~=neutral_start_mcs; EOL*; SEMICOLON?; EOL*; RBRACE; <>
  | LBRACE; EOL*; ~=non_neutral_start_mcs; EOL*; RBRACE; <>
  | ~=non_neutral_start_mcs; <>

galaxy_block:
| PROCESS; EOL*; { Process [] }
| PROCESS; EOL*; l=process_item+; { Process l }

process_item:
| e=galaxy_content; DOT; EOL*; { e }
