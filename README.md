# Context: stellar resolution

The stellar resolution (RS) is a model of computation introduced by Jean-Yves
Girard [1] in his transcendental syntax project as a basis for the study of the
computational foundations of logic. It has been mainly developed
by Eng later in his PhD thesis [2].

It is basically a logic-agnostic, asynchronous and very general version of
Robinson's first order resolution with disjunctive clauses, which is used in
logic programming.

In this model, computation is done by making independent agents/bricks locally
interact which each other. Those agents match and propagate information by
using term unification [2]. It can be seen as a non-planar generalisation of
Wang tiles.

# Large Star Collider

The Large Star Collider (LSC) is an implementation of stellar resolution which
interprets and executes objects called *constellations*, which are the programs
of stellar resolution.

## Syntax

A **ray** is a term which is either a variable or a possibly polarised function
symbol taking other rays as arguments. Example:
```
X
f(X)
+a(X, Y)
-h(f(X, Y))
+a(+f(X), h(-f(X))
```
Identifiers in uppercase (possibly with a suffix number are variables and
identifiers in lowercase (possibly containing a `_` symbol and digits, but
always beginning by an alphabetic character) are function symbols.

> [!NOTE]
> There is a special infix binary symbol `:` used to concatenate constants.
> For instance, the encoding of the word `0101` can be written `0:1:0:1` where
> `e` can represent the empty string. This is only syntactic sugar to make
> programs clearer but any binary symbol can be used for concatenation and any
> constant can represent the empty string.

A **star** is a sequence of rays which can be separated by a comma:
```
X, f(X), +a(X,Y), -h(f(X, Y))
X f(X) +a(X,Y) -h(f(X, Y))
```

A **constellation** is a sequence of stars separated by a semicolon, in which
every variables are local to their star:
```
X, f(X);
+a(X,Y);
-h(f(X, Y)) +a(+f(X), h(-f(X));
```
The `X`s on the first line are local and distinct from the other occurrences of
`X` below.

## Computation

You have to select initial stars (the initial pieces of the puzzle) by
prefixing them with a `@` symbol as in:
```
X, f(X);
+a(X,Y);
@-h(f(X, Y)) +a(+f(X), h(-f(X));
```

The LSC will put marked stars in an *interaction space* and make them collide
with copies of other matching stars until there is no interaction possible
anymore. At the end, the result of the interaction space is outputted.

Collision between stars, called *fusion* (noted `<>` here) is done by using
the principle of Robinson's resolution rule:
- rays can *compatible* or *unifiable* when there exists a substitution of
  variables making the two rays equal (considering variables are renamed to
  make them disjoint) such that matching function symbols are of opposite
  polarity (`+` against `-`);
- consider a fusion `r1 ... rk +f(X) <> r1' ... rk' -f(a)` between two stars;
- we see that `+f(X)` matches `-f(a)` with unifier `{X := a}`;
- the two rays are annihilated and `{X := a}` is propagated;
- we obtain `{X:=a}r1 ... {X:=a}rk {X:=a}r1' ... {X:=a}rk'`;

Here is a trivial example:
```
X +f(X) <> -f(a) == a
```

And a non-trivial one:
```
+7(l:X) +7(r:X); 3(X) +8(l:X); @+8(r:X) 6(X);
-7(X) -8(X);
```
We have:
```
+8(r:X) 6(X) <> -7(X) -8(X) == -7(r:X) 6(X)
```
Hence we obtain:
```
+7(l:X) +7(r:X); 3(X) +8(l:X); @-7(r:X) 6(X);
-7(X) -8(X);
```
We have:
```
-7(r:X) 6(X) <> +7(l:X) == +7(r:X) 6(X)
```
The ray `-7(r:X)` only matches with `+7(r:X)`, hence only `+7(l:X)` is left.
We obtain:
```
+7(l:X) +7(r:X); 3(X) +8(l:X); @+7(l:X) 6(X);
-7(X) -8(X);
```
We have:
```
+7(l:X) 6(X) <> -7(X) -8(X) == -8(l:X) 6(X)
```
We obtain:
```
+7(l:X) +7(r:X); 3(X) +8(l:X); @-8(l:X) 6(X);
-7(X) -8(X);
```
We have:
```
-8(l:X) 6(X) <> +8(l:X) 3(X) == 6(X) 3(X)
```
The result of the computation is
```
6(X) 3(X)
```

This computation corresponds to what we call cut-elimination for the proof
structures of multiplicative linear logic.

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
opam install base
opam install menhir
```

Build the project
```
dune build
```

The executable is `_build/default/bin/lsc.exe`.

## Commands

Assume the executable is named `lsc.exe`. Execute the program with:

```
./lsc.exe [-showsteps] [-noloops] <inputfile>
```
where `-noloops` forbids trivial equations `X=X` during computation.
This equation usually yields trivial loops linking two rays of a same star.
This is something which can be unwanted in some cases.

# Examples

Some example files with the `.stellar` extension in `/examples` are ready to be
executed. Below, some explanations of how to create other examples are given.
In Eng's thesis, ways to work with other models of computation is a simple way
are provided (Turing machines, pushdown automata, transducers, alternating
automata etc).

## Constructing logic programs

Facts are stars `+p(t1 ... tn)` and inference rules `P(t11, ..., t1n), ...
P(tn1, ..., tnm) => P(u1, ..., uk)` are stars `-p(t11 ... t1n) ... -p(tn1
... tnm) +p(u1 ... uk)` where negative rays are inputs (hypotheses) and
the only positive ray is the output (conclusion).

Queries are stars `+q(v1 ... vl X1 ... Xp]` where `+q(v1 ... vl)`
corresponds to the query and `X1 ... Xp` are variables occurring in the query
that we would like to display in the result.

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
-i(W) +a(W q0);
-a(e q2) accept;
-a(0:W q0) +a(W q0);
-a(0:W q0) +a(W q1);
-a(0:W q1) +a(W q2);
-a(1:W q0) +a(W q0);
@+i(0:0:0:e);
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
sufficient to put a star with a free (even unpolarised) ray in the interaction
space and put the other stars in the reference constellation.

# References

- [1] [Transcendental syntax I: deterministic case, Jean-Yves Girard.](https://girard.perso.math.cnrs.fr/trsy1.pdf)
- [2] [An exegesis of transcendental syntax, Boris Eng.](https://hal.science/tel-04179276v1)
- [3] Term Rewriting and All That, Franz Baader & Tobias Nipkow.
