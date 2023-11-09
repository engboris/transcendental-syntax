%token COMMA
%token LEFT_BRACK RIGHT_BRACK
%token LEFT_PAR RIGHT_PAR
%token LEFT_BRACE RIGHT_BRACE
%token <string> VAR
%token <string> SYM
%token PLUS MINUS
%token DOT
%token VDASH

%right DOT

%start <Stellar.constellation * Stellar.constellation> spacec
%start <Stellar.constellation> constc

%%

spacec:
| cs = constc; VDASH; space = constc { (cs, space) }

constc:
| LEFT_BRACE; cs = separated_list(PLUS, starc); RIGHT_BRACE { cs }

starc:
| LEFT_BRACK; rs = separated_list(COMMA, rayc); RIGHT_BRACK { rs }

symc:
| PLUS; f = SYM { (Pos, f) }
| MINUS; f = SYM { (Neg, f) }
| f = SYM { (Stellar.Null, f) }

rayc:
| x = VAR { Stellar.to_var x }
| r1 = rayc; DOT; r2 = rayc { Stellar.to_func ((Stellar.Null, "."), [r1; r2]) }
| pf = symc; LEFT_PAR; ts = separated_nonempty_list(COMMA, rayc); RIGHT_PAR
	{ Stellar.to_func (pf, ts) }
| pf = symc { Stellar.to_func (pf, []) }
