# Context: stellar resolution

The stellar resolution (RS) is a model of computation introduced by Jean-Yves
Girard [1] in his transcendental syntax project as a basis for the study of the
computational foundations of logic. It has been mainly developed by Eng later
in his PhD thesis [2].

It can be understood from several points of view:
- it is a logic-agnostic, asynchronous and very general version of Robinson's
first-order resolution with disjunctive clauses, which is used in logic
programming;
- it is a very elementary logic-agnostic constraint programming language;
- it is a non-planar generalization of Wang tiles (or LEGO bricks) using terms
instead of colours and term unification instead of colour matching;
- it is a model of interactive agents behaving like molecules which interact
with each other. It can be seen as a generalization of Jonoska's flexible
tiles used in DNA computing;
- it is an assembly language for meaning.

Stellar resolution is very elementary and an interpreter for it can be written
in a very concise way since it mostly relies on a unification algorithm.

# Large Star Collider

The Large Star Collider (LSC) is an implementation of stellar resolution that
interprets and executes objects called *constellations*, which are the programs
of stellar resolution.

Go to https://tsguide.refl.fr/ to learn more about how to write programs.

# Use

You can either download a released binary (or ask for a binary) or build the
program from sources.

## Build from sources

Install `opam` and OCaml from `opam` : https://ocaml.org/docs/installing-ocaml

Install `dune`:
```
opam install dune
```

Install dependencies
```
opam install . --deps-only
```

Build the project
```
dune build
```

The executable is `_build/default/bin/lsc.exe`. You can launch it with:
```bash
dune exec lsc -- <args>
```

## Commands

Assume the executable is named `lsc.exe`. Execute the program with:

```
./lsc.exe [-options] <inputfile>
```

or if you use Dune:

```
dune exec lsc -- [-options] <inputfile>
```

# Examples

Some example files with the `.stellar` extension in `/examples` are ready to be
executed. In Eng's thesis, ways to work with other models of computation are described
(Turing machines, pushdown automata, transducers, alternating automata etc).

# References

- [1] [Transcendental syntax I: deterministic case, Jean-Yves Girard.](https://girard.perso.math.cnrs.fr/trsy1.pdf)
- [2] [An exegesis of transcendental syntax, Boris Eng.](https://hal.science/tel-04179276v1)
- [3] Term Rewriting and All That, Franz Baader & Tobias Nipkow.
