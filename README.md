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
./lsc.exe [-showsteps] [-noloops] <inputfile>
```

# Examples

Some example files with the `.stellar` extension in `/examples` are ready to be
executed. Below, some explanations of how to create other examples are given.
In Eng's thesis, ways to work with other models of computation are described
(Turing machines, pushdown automata, transducers, alternating automata etc).

## Constructing logic programs

Facts are stars `+p(t1 ... tn)` and inference rules `P(t11, ..., t1n), ...
P(tn1, ..., tnm) => P(u1, ..., uk)` are stars `-p(t11 ... t1n) ... -p(tn1
... tnm) +p(u1 ... uk)` where negative rays are inputs (hypotheses) and
the only positive ray is the output (conclusion).

Queries are stars `+q(v1 ... vl X1 ... Xp]` where `+q(v1 ... vl)`
corresponds to the query and `X1 ... Xp` are variables occurring in the query
that we would like to display in the result.

Example:
```
+add(0 Y Y);
-add(X Y Z) +add(s(X) Y s(Z));

@-add(s(s(0)) s(s(0)) R) R; 'query
```

## Constructing finite automata

The encoding of a finite automaton must include the following stars:
- `-i(W) +a(W q0)` encoding the initial state
  (where `q0` can be replaced by any other name);
- `-a(e qf) accept` encoding the accepting/final state (where `qf` can be
  replaced by any other name and `e` represents the empty word).

Each transition from a state `q1` to another state `q2` along the character `a`
is encoded by a star:
```
-a(a:W q1) +a(W q2)
```

Words are encoded by sequences of characters separated by the binary symbol `:`
and ending with `e`. For example: `0:0:1:e`, `e` or `1:b:c:e` encode words.

Example of a marked constellation (ready to be executed) encoding an automaton:
```
-i(W) +a(W q0); 'initial state
-a(e q2) accept; 'final state

-a(0:W q0) +a(W q0);
-a(0:W q0) +a(W q1);
-a(0:W q1) +a(W q2);
-a(1:W q0) +a(W q0);

@+i(0:0:0:e); 'input word
```

## Constructing proof-structures of multiplicative linear logic

It is recommended to follow the method suggested in Eng's thesis.
Each axiom becomes a binary star containing the translation of its atoms.

The translation of an atom `a` accessible from a conclusion `c` is given by a
ray `+c(t)` where `t` is a sequence of symbols `l` (left) and `r` (right)
separated by the binary symbol `:` and ending with the variable `X`.
The idea is to encode the path from `c` to `a` by sequence of directions in the
proof-structure.

For instance, if from a conclusion `c`, we need to go up by going left two
times and right once in order to reach `a`, the translation of `a` will be
`+c(l:l:r:X)`.

A cut connecting the conclusions `c1` and `c2` is simply encoded by a star
`-c1(X) -c2(X)`.

Since proof-structures can be traversed by starting from any free atom, it is
sufficient to put a star with a free (even unpolarized) ray in the interaction
space and put the other stars in the reference constellation.

# References

- [1] [Transcendental syntax I: deterministic case, Jean-Yves Girard.](https://girard.perso.math.cnrs.fr/trsy1.pdf)
- [2] [An exegesis of transcendental syntax, Boris Eng.](https://hal.science/tel-04179276v1)
- [3] Term Rewriting and All That, Franz Baader & Tobias Nipkow.
