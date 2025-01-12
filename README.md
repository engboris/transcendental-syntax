# Transcendental Syntax

**Note: this project is an experimental proof of concept, not a fully designed
and specified programming language.**

The transcendental syntax is a method of constructing logical abstractions from
a low-level elementary and "logic-agnostic" language.

This elementary language we use to build abstractions is called
"stellar resolution" and its elementary objects corresponding to programs are
called "constellations".

Those constellations are used in a higher-level language called "Stellogen" in
which notions such as proofs and formulas are defined (this is basically a
metaprogramming language for constellations). By the proof-as-program
correspondence, this can be extended to programs and types.

## Stellar resolution

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

## Learn

This project is still in development, hence the syntax and features are still
changing.

To learn more about how to play with the current implementation of transcendental
syntax:
- French guide (official): https://tsguide.refl.fr/
- English guide: https://tsguide.refl.fr/en/

# Use

You can either download a [released
binary](https://github.com/engboris/large-star-collider/releases) (or ask for a
binary), install using [opam](https://opam.ocaml.org/), or build the program from
sources.

## Install using opam

Install [opam](https://ocaml.org/docs/installing-ocaml).

Install the latest development version of the package from this repo with

```
opam pin tsyntax https://github.com/engboris/transcendental-syntax.git
```

## Build from sources

Install `opam` and OCaml from `opam` : https://ocaml.org/docs/installing-ocaml

Install `dune`:
```
opam install dune
```

Install dependencies
```
opam install . --deps-only --with-test
```

Build the project
```
dune build
```

Executables are in `_build/default/bin/`.

## Commands

Assume the executable is named `sgen.exe`. Interpreter Stellogen programs with:

```
./sgen.exe
```

or if you use Dune:

```
dune exec sgen -- <inputfile>
```

# Examples

Some example files with the `.sg` extension in `/examples` are ready to be
executed. In Eng's thesis, ways to work with other models of computation are
described (Turing machines, pushdown automata, transducers, alternating
automata etc).

# References

- [1] [Transcendental syntax I: deterministic case, Jean-Yves Girard.](https://girard.perso.math.cnrs.fr/trsy1.pdf)
- [2] [An exegesis of transcendental syntax, Boris Eng.](https://hal.science/tel-04179276v1)
- [3] Term Rewriting and All That, Franz Baader & Tobias Nipkow.
