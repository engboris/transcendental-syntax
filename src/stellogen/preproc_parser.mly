%{
  exception Eof
%}

%token <string> INCLUDE
%token <char> CHAR

%start <string> preprocess

%%

preprocess:
| EOF { raise Eof }
| i=instruction; p=preprocess { i^p }
| i=instruction; { i }

instruction:
| f=INCLUDE { "" }
| x=CHAR { String.make 1 x }
