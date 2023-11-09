CC = ocamlc
MAIN = exec

all: $(MAIN)

$(MAIN): tools.cmo unification.cmo stellar.cmo parser.cmo lexer.cmo main.cmo
	$(CC) $^ -o $(MAIN)

parser.ml: parser.mly
	menhir --infer $^
	$(CC) -c parser.mli
	
lexer.ml: lexer.mll
	ocamllex $^

%.cmo: %.ml
	$(CC) -c $^
	
%.cmi: %.mli
	$(CC) -c $^

.PHONY: clean

clean:
	@echo "Project clean."
	@rm -rf *.cmi *.cmo *.cmx *.mli *.o parser.ml lexer.ml parser.conflicts $(MAIN)