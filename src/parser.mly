%token COMMA
%token LEFT_BRACK RIGHT_BRACK
%token LEFT_PAR RIGHT_PAR
%token <string> VAR
%token <string> SYM
%token PLUS MINUS
%token CONS
%token AT
%token SEMICOLON
%token PLACEHOLDER
%token EMPTY_SYM
%token EOF

%right CONS

%start <Stellar.marked_constellation> marked_constellation

%%

marked_constellation:
| EOF { [] }
| cs = nonempty_list(star); EOF { cs }

star:
| AT; s = star_content; SEMICOLON { Stellar.Marked s }
| s = star_content; SEMICOLON { Stellar.Unmarked s }

star_content:
| LEFT_BRACK; RIGHT_BRACK { [] }
| rs = separated_nonempty_list(COMMA?, ray) { rs }

symbol:
| PLUS; f = SYM { (Pos, f) }
| MINUS; f = SYM { (Neg, f) }
| f = SYM { (Stellar.Null, f) }

ray:
| EMPTY_SYM { Stellar.to_func ((Stellar.Null, "$"), []) }
| PLACEHOLDER { Stellar.to_var ("_"^(Stellar.fresh_placeholder ())) }
| x = VAR { Stellar.to_var x }
| r1 = ray; CONS; r2 = ray { Stellar.to_func ((Stellar.Null, ":"), [r1; r2]) }
| pf = symbol; LEFT_PAR; ts = separated_nonempty_list(COMMA?, ray); RIGHT_PAR
	{ Stellar.to_func (pf, ts) }
| pf = symbol { Stellar.to_func (pf, []) }
