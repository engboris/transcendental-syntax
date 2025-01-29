%{
open Sgen_ast
open Lexing

%}

%token LBRACE RBRACE
%token SHOW SHOWEXEC
%token EXEC
%token IMPORT
%token RUN
%token TRACE
%token PROCESS
%token GALAXY
%token RANGLE
%token RARROW DRARROW
%token EQ
%token DOT
%token END

%start <Sgen_ast.program> program

%%

let program :=
  | EOL*; EOF; { [] }
  | EOL*; d=declaration; EOL+; p=program; { d::p }
  | EOL*; d=declaration; EOF; { [d] }

let declaration :=
  | ~=SYM; EQ; EOL*; ~=galaxy_expr; <Def>
  | SHOW; EOL*; ~=galaxy_expr;      <Show>
  | SHOWEXEC; EOL*; ~=galaxy_expr;  <ShowExec>
  | TRACE; EOL*; ~=galaxy_expr;     <Trace>
  | RUN; EOL*; ~=galaxy_expr;       <Run>
  | ~=SYM; CONS; CONS; ~=SYM; EOL*;
    ~=checker_def; DOT;             <TypeDef>
  | x=SYM; CONS; CONS; t=SYM; DOT;  { TypeDef (x, t, None) }
  (* | IMPORT; EOL*; ~=import_target;
    EOL*; DOT;                      {
  } *)

let import_target :=
  | ~=separated_nonempty_list(RANGLE, VAR); <Module>

let checker_def :=
  | LBRACK; ~=SYM; RBRACK; <Some>
  | LBRACK; RBRACK;        { None }

let galaxy_expr :=
  | ~=galaxy_content; DOT; <>
  | ~=galaxy_block; END;   <>
  | g=galaxy_def; END;     { Raw (Galaxy g) }

let galaxy_content :=
  | LPAR; ~=galaxy_content; RPAR;       <>
  | LBRACE; EOL*; RBRACE;               { Raw (Const []) }
  | SHARP; ~=SYM;                       <Token>
  | cs=raw_constellation;               { Raw (Const cs) }
  | ~=SYM;                              <Id>
  | g=galaxy_content; EOL*;
    h=galaxy_content; EOL*;             { Union (g, h) }
  | ~=galaxy_content; RARROW; ~=SYM;    <Access>
  | ~=galaxy_content;
    LBRACK; DRARROW; ~=symbol; RBRACK;  <Extend>
  | ~=galaxy_content;
    LBRACK; ~=symbol; DRARROW; RBRACK;  <Reduce>
  | LPAR; AT; ~=galaxy_content; RPAR;   <Focus>
  | ~=galaxy_content; LBRACK; x=VAR;
    DRARROW; r=ray; RBRACK;             <SubstVar>
  | e=galaxy_content; LBRACK; f=symbol;
    DRARROW; g=symbol; RBRACK;          { SubstFunc (e, f, g) }
  | g=galaxy_content; LBRACK; x=SYM;
    DRARROW; h=galaxy_content; RBRACK;  { SubstGal (g, x, h) }

%public let non_neutral_singleton_mcs :=
  | pf=pol_symbol; ts=args?; EOL*;
    rs=separated_list(pair(COMMA?, EOL*), ray); EOL*; bs=bans?;
    {
      [ Unmarked {
          content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
          bans = Option.to_list bs |> List.concat
        }
      ]
    }
  | AT; pf=pol_symbol; ts=args?; EOL*;
    rs=separated_list(pair(COMMA?, EOL*), ray); EOL*; bs=bans?;
    {
      [ Marked {
          content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
          bans = Option.to_list bs |> List.concat
        }
      ]
    }
  | nmcs=non_neutral_singleton_mcs; EOL*; SEMICOLON; EOL*;
    mcs=marked_constellation;
    { nmcs @ mcs }

let raw_constellation :=
  | LBRACE; EOL*; pf=unpol_symbol; ts=args?; EOL*; bs=bans?; EOL*; RBRACE;
    {
      [ Unmarked {
          content = [to_func (pf, Option.to_list ts |> List.concat)];
          bans = Option.to_list bs |> List.concat
        }
      ]
    }
  | LBRACE; EOL*; LBRACK; EOL*; pf=unpol_symbol; ts=args?; EOL*; RBRACK;
    EOL*; bs=bans?; EOL*; RBRACE;
    {
      [ Unmarked {
          content = [to_func (pf, Option.to_list ts |> List.concat)];
          bans = Option.to_list bs |> List.concat
        }
      ]
    }
  | LBRACE; EOL*;
    pf=unpol_symbol; ts=args?; EOL*;
    rs=separated_nonempty_list(pair(COMMA?, EOL*), ray); EOL*; bs=bans?;
    EOL*; RBRACE;
    {
      [ Unmarked {
          content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
          bans = Option.to_list bs |> List.concat
        }
      ]
    }
  | LBRACE; EOL*; LBRACK; EOL*;
    pf=unpol_symbol; ts=args?; EOL*;
    rs=separated_nonempty_list(pair(COMMA?, EOL*), ray); EOL*; bs=bans?;
    EOL*; RBRACK; EOL*; RBRACE;
    {
      [ Unmarked {
          content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
          bans = Option.to_list bs |> List.concat
        }
      ]
    }
  | LBRACE; EOL*;
    pf=unpol_symbol; ts=args?; EOL*;
    rs=separated_list(pair(COMMA?, EOL*), ray); EOL*; bs=bans?; EOL*;
    SEMICOLON; EOL*;
    cs=separated_nonempty_list(pair(SEMICOLON, EOL*), star); SEMICOLON?;
    EOL*; RBRACE;
    {
      (Unmarked {
        content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
        bans = Option.to_list bs |> List.concat
      })
      :: cs
    }
  | LBRACE; EOL*; LBRACK; EOL*;
    pf=unpol_symbol; ts=args?; EOL*;
    rs=separated_list(pair(COMMA?, EOL*), ray); EOL*; bs=bans?; EOL*;
    RBRACK; EOL*; SEMICOLON; EOL*;
    cs=separated_nonempty_list(pair(SEMICOLON, EOL*), star); SEMICOLON?;
    EOL*; RBRACE;
    {
      (Unmarked {
        content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
        bans = Option.to_list bs |> List.concat
      })
      :: cs
    }
  | LBRACE; EOL*; ~=non_neutral_singleton_mcs; EOL*; RBRACE; <>
  | ~=non_neutral_singleton_mcs; <>

let galaxy_def :=
  | GALAXY; EOL*; ~=galaxy_item+; <>

let galaxy_item :=
  | ~=SYM; CONS; EOL*; ~=galaxy_content; DOT; EOL*; <>
  | ~=SYM; CONS; EOL*; ~=galaxy_block; END; EOL*; <>

let galaxy_block :=
  | PROCESS; EOL*; { Process [] }
  | PROCESS; EOL*; ~=process_item+; <Process>
  | EXEC; EOL*; ~=galaxy_content; <Exec>

let process_item :=
  | ~=galaxy_content; DOT; EOL*; <>
