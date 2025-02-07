%{
open Sgen_ast
%}

%token SHOW SHOWEXEC
%token EXEC
%token RUN
%token TRACE
%token PROCESS
%token GALAXY
%token RARROW DRARROW
%token EQ
%token DOT
%token END

%start <Sgen_ast.program> program

%%

let program :=
  | EOL*; EOF;                            { [] }
  | EOL*; d=declaration; EOL+; p=program; { d::p }
  | EOL*; d=declaration; EOF;             { [d] }

let declaration :=
  | ~=SYM; EOL*; EQ; EOL*; ~=galaxy_expr;   <Def>
  | SHOW; EOL*; ~=galaxy_expr;              <Show>
  | SHOWEXEC; EOL*; ~=galaxy_expr;          <ShowExec>
  | TRACE; EOL*; ~=galaxy_expr;             <Trace>
  | RUN; EOL*; ~=galaxy_expr;               <Run>
  | ~=SYM; CONS; CONS;
    ~=separated_nonempty_list(COMMA, SYM);
    EOL*; ~=checker_def; DOT;               <TypeDef>
  | x=SYM; CONS; CONS;
    ts=separated_nonempty_list(COMMA, SYM);
    DOT;                                    { TypeDef (x, ts, None) }

let checker_def :=
  | ~=bracks(SYM); <Some>
  | bracks(EOL*);  { None }

let galaxy_expr :=
  | ~=galaxy_content; EOL*; DOT;          <>
  | mcs=non_neutral_start_mcs; EOL*; DOT; { Raw (Const mcs) }
  | ~=galaxy_block; END;                  <>
  | g=galaxy_def; END;                    { Raw (Galaxy g) }

let galaxy_content :=
  | ~=pars(galaxy_content);             <>
  | mcs=pars(non_neutral_start_mcs);    { Raw (Const mcs) }
  | braces(EOL*);                       { Raw (Const []) }
  | SHARP; ~=SYM;                       <Token>
  | cs=braces(neutral_start_mcs);       { Raw (Const cs) }
  | cs=braces(non_neutral_start_mcs);   { Raw (Const cs) }
  | ~=SYM;                              <Id>
  | g=galaxy_content; EOL*;
    h=galaxy_content; EOL*;             { Union (g, h) }
  | ~=galaxy_content; RARROW; ~=SYM;    <Access>
  | ~=galaxy_content;
    LBRACK; DRARROW; ~=symbol; RBRACK;  <Extend>
  | ~=galaxy_content;
    LBRACK; ~=symbol; DRARROW; RBRACK;  <Reduce>
  | LPAR; EOL*; AT; EOL*;
    ~=galaxy_content; RPAR;             <Focus>
  | ~=galaxy_content; LBRACK; x=VAR;
    DRARROW; r=ray; RBRACK;             <SubstVar>
  | e=galaxy_content; LBRACK; f=symbol;
    DRARROW; g=symbol; RBRACK;          { SubstFunc (e, f, g) }
  | g=galaxy_content; LBRACK; x=SYM;
    DRARROW; h=galaxy_content; RBRACK;  { SubstGal (g, x, h) }
  | g=galaxy_content; LBRACK; x=SYM;
    DRARROW; h=non_neutral_start_mcs;
    RBRACK;                             { SubstGal (g, x, Raw (Const h)) }

%public let non_neutral_start_mcs :=
  (* single star *)
  | marked=AT?; EOL*; pf=pol_symbol; ts=args?; EOL*;
    rs=separated_list(pair(COMMA?, EOL*), ray); EOL*; bs=bans?;
    {
      [ { content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
          bans = Option.to_list bs |> List.concat }
        |> if Option.is_some marked then mark else unmark ]
    }
  | LBRACK; EOL*; marked=AT?; EOL*; pf=pol_symbol; ts=args?; EOL*;
    rs=separated_list(pair(COMMA?, EOL*), ray); EOL*; RBRACK; EOL*;
    bs=bans?;
    {
      [ { content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
          bans = Option.to_list bs |> List.concat }
        |> if Option.is_some marked then mark else unmark ]
    }
  (* more than one star *)
  | nmcs=non_neutral_start_mcs; EOL*; SEMICOLON; EOL*; mcs=marked_constellation;
    { nmcs @ mcs }

let neutral_start_mcs :=
  (* single ray *)
  | marked=AT?; EOL*; pf=unpol_symbol; ts=args?; EOL*; bs=bans?;
    {
      [ { content = [to_func (pf, Option.to_list ts |> List.concat)];
          bans = Option.to_list bs |> List.concat }
        |> if Option.is_some marked then mark else unmark ]
    }
  | LBRACK; EOL*; marked=AT?; EOL*; pf=unpol_symbol; ts=args?; EOL*;
    RBRACK; EOL*; bs=bans?;
    {
      [ { content = [to_func (pf, Option.to_list ts |> List.concat)];
          bans = Option.to_list bs |> List.concat }
        |> if Option.is_some marked then mark else unmark ]
    }
  (* single star *)
  | marked=AT?; EOL*; pf=unpol_symbol; ts=args?; EOL*;
    rs=separated_nonempty_list(pair(COMMA?, EOL*), ray); EOL*; bs=bans?;
    {
      [ { content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
          bans = Option.to_list bs |> List.concat }
        |> if Option.is_some marked then mark else unmark ]
    }
  | LBRACK; EOL*; marked=AT?; EOL*; pf=unpol_symbol; ts=args?; EOL*;
    rs=separated_nonempty_list(pair(COMMA?, EOL*), ray); EOL*; bs=bans?;
    EOL*; RBRACK;
    {
      [ { content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
          bans = Option.to_list bs |> List.concat }
        |> if Option.is_some marked then mark else unmark ]
    }
  (* general constellation *)
  | marked=AT?; EOL*; pf=unpol_symbol; ts=args?; EOL*;
    rs=separated_list(pair(COMMA?, EOL*), ray); EOL*;
    bs=bans?; EOL*; SEMICOLON; EOL*;
    cs=separated_nonempty_list(pair(SEMICOLON, EOL*), star);
    {
      ({ content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
         bans = Option.to_list bs |> List.concat }
         |> if Option.is_some marked then mark else unmark) :: cs
    }
  | LBRACK; EOL*; marked=AT?; EOL*; pf=unpol_symbol; ts=args?; EOL*;
    rs=separated_list(pair(COMMA?, EOL*), ray); EOL*; bs=bans?; EOL*;
    RBRACK; EOL*; SEMICOLON; EOL*;
    cs=separated_nonempty_list(pair(SEMICOLON, EOL*), star);
    {
      ({ content = ((to_func (pf, Option.to_list ts |> List.concat)) :: rs);
         bans = Option.to_list bs |> List.concat }
         |> if Option.is_some marked then mark else unmark) :: cs
    }

let raw_constellation :=
  | ~=braces(neutral_start_mcs); <>
  | ~=braces_opt(non_neutral_start_mcs); <>

let galaxy_def :=
  | GALAXY; EOL*; ~=galaxy_item+; <>

let galaxy_item :=
  | ~=SYM; CONS; EOL*; ~=galaxy_content; DOT; EOL*; <>
  | x=SYM; CONS; EOL*; mcs=non_neutral_start_mcs; DOT; EOL*;
    { (x, Raw (Const mcs)) }
  | ~=SYM; CONS; EOL*; ~=galaxy_block; END; EOL*; <>

let galaxy_block :=
  | PROCESS; EOL*; { Process [] }
  | PROCESS; EOL*; ~=process_item+; <Process>
  | EXEC; EOL*; ~=galaxy_content; <Exec>
  | EXEC; EOL*; mcs=non_neutral_start_mcs; { Exec (Raw (Const mcs)) }

let process_item :=
  | ~=galaxy_content; DOT; EOL*; <>
  | mcs=non_neutral_start_mcs; DOT; EOL*; { Raw (Const mcs) }
