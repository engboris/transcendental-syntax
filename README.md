# Stellogen

**Note: this project is an experimental proof of concept, not a fully
designed and specified programming language.**

Stellogen is a minimalistic and *logic-agnostic* programming language based on
term unification.

It draws inspiration (or try to draw inspiration) from Prolog
(unification-based computation), Smalltalk (message-passing, object-oriented
programming, minimalism), Coq (proof-as-program paradigm, iterative programming
with tactics), Scheme/Racket (minimalism and metaprogramming), Haskell/Ruby
(for their syntax).

It has the following characteristics:
- it can naturally describe state machines, logic programs and tiling systems;
- it is typed (with dynamic and/or static types) but has no primitive type;
- everything is a "galaxy" (similarly to the "everything is an object" paradigm,
except that even types are galaxies);
- types/formulas/specifications are defined by a set of tests which are
themselves expressed by galaxies and typechecking is interaction between those
galaxy-tests and some subject galaxy;
- it extends the Curry-Howard correspondence with galaxies-as-proofs (which are
more primitive than lambda-terms).

## Transcendental syntax

Its design is based on Girard's transcendental syntax programme which proposes
new foundations for logic and computation. This programme provides a method of
constructing logical abstractions (such as proofs and types) from an elementary
"logic-agnostic" language.

In particular, its framework works well with a model of computation called
*stellar resolution* (introduced by Girard [1] but named and developed by Eng
[2]). This model of computation works with brick-like objects holding terms and
interacting with each other using term unification.

It can be understood from several points of view:
- it is a logic-agnostic, asynchronous and very general version of Robinson's
first-order resolution with disjunctive clauses, which is used in logic
programming;
- it is a very elementary constraint programming language;
- it is a non-planar generalization of Wang tiles using terms instead of
colours and term unification instead of colour matching;
- it is a model of interactive agents behaving like molecules which interact
with each other. It can be seen as a generalization of Jonoska's flexible tiles
used in DNA computing;
- it is an assembly language for logical meaning.

Stellar resolution is very elementary and an interpreter for it can be written
in a very concise way since it mostly relies on a unification algorithm.

## Syntax sample

```
binary =
  -i(e) ok;
  -i(0:X) +i(X);
  -i(1:X) +i(X).

'input words
e :: binary.
e = +i(e).

000 :: binary.
000 = +i(0:0:0:e).

010 :: binary.
010 = +i(0:1:0:e).

110 :: binary.
110 = +i(1:1:0:e).

a1 = galaxy
  initial:
    -i(W) +a(W q0).
  final:
    -a(e q2) accept.
  transitions:
    -a(0:W q0) +a(W q0);
    -a(0:W q0) +a(W q1);
    -a(1:W q0) +a(W q0);
    -a(0:W q1) +a(W q2).
end

show process e.   a1. kill. end
show process 000. a1. kill. end
show process 010. a1. kill. end
show process 110. a1. kill. end
```

## Learn

This project is still in development, hence the syntax and features are still
changing frequently.

To learn more about the current implementation of transcendental syntax:
- French guide (official): https://tsguide.refl.fr/
- English guide: https://tsguide.refl.fr/en/

# Use

You can either download a
[released binary](https://github.com/engboris/stellogen/releases)
(or ask for a binary), install using
[opam](https://opam.ocaml.org/), or build the program from sources.

## Install using opam

Install [opam](https://ocaml.org/docs/installing-ocaml).

Install the latest development version of the package from this repo with

```
opam pin tsyntax https://github.com/engboris/stellogen.git
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
./sgen.exe <inputfile>
```

or if you use Dune:

```
dune exec sgen -- <inputfile>
```

# Examples of programs

Some example files with the `.sg` extension in `/examples` are ready to be
executed. In Eng's thesis, ways to work with other models are described
(Turing machines, pushdown automata, transducers, alternating automata,
proof-nets of linear logic etc).

# References

- [1] [Transcendental syntax I: deterministic case, Jean-Yves Girard.](https://girard.perso.math.cnrs.fr/trsy1.pdf)
- [2] [An exegesis of transcendental syntax, Boris Eng.](https://hal.science/tel-04179276v1)
- [3] Term Rewriting and All That, Franz Baader & Tobias Nipkow.
