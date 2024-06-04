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

## Syntax

A **ray** is a term which is either a variable or a possibly polarized function
symbol taking other rays as arguments (separated by comma or space). Example:
```
X
f(X)
+a(X,Y)
-h(f(X Y))
+a(+f(X) h(-f(X))
```
Identifiers in uppercase (possibly with a suffix number) are variables and
identifiers in lowercase (possibly containing a `_` symbol and digits, but
always starting with an alphabetic character) are function symbols.

> [!NOTE]
> There is a special infix binary symbol `:` used to concatenate constants.
> For instance, the encoding of the word `0101` can be written `0:1:0:1:e` where
> `e` can represent the empty string. This is only syntactic sugar to make
> programs clearer but any binary symbol can be used for concatenation and any
> constant can represent the empty string. Another possible encoding is
> `0(1(0(1(e))))`.

> [!NOTE]
> Function symbols do not have to be coherent. The same symbol can be used
> with several different arities. For instance, `f(X)` and `f(X, Y)` can occur
> in the same program.

A **star** is an unordered sequence of rays separated by commas or whitespace:
```
X, f(X), +a(X,Y), -h(f(X, Y))
X f(X) +a(X,Y) -h(f(X, Y))
```

A **constellation** is an unordered sequence of stars ending by a semicolon in
which all variables are local to their star:
```
X, f(X); +a(X Y);
-h(f(X Y)) +a(+f(X) h(-f(X));
```
The `X`s on the first line are local and distinct from the other occurrences of
`X` below. Hence it can be convenient to use different variable names to make
it explicit.

You can write comments with `'` and multiline comments are delimited by `'''`:
```
'this is a comment on a single line

'''
this is a comment
on several lines
'''
```

## Computation

### Fusion

Stars are able to interact, through an operation called *fusion*, by using the
principle of Robinson's resolution rule. We define an operator `<i,j>` with
connects the `i`th ray of a star to the `j`th ray of another star.

Rays are *compatible* or *unifiable* when there exists a substitution of
variables making the two rays equal (considering variables are renamed to
make them disjoint) such that matching function symbols are of opposite
polarity (`+` against `-`). For instance `+f(X)` and `-f(a)` are unifiable
but not `+f(X)` and `+f(a)`, nor `+f(X)` and `-g(a)`.

- consider a fusion `+f(X) r1 ... rk <0,0> -f(a) r1' ... rk'` between two stars;
- we see that `+f(X)` matches `-f(a)` with unifier `{X := a}`;
- the two connected rays are annihilated and `{X := a}` is propagated to
  other rays;
- we obtain
	```
	+f(X) r1 ... rk <0,0> -f(a) r1' ... rk' == {X:=a}r1 ... {X:=a}rk {X:=a}r1' ... {X:=a}rk'`;
	```

For example:
```
X +f(X) <1,0> -f(a) == a
```

> [!NOTE]
> This corresponds to the cut rule for first-order logic except that we are
> in a logic-agnostic setting (our symbols do not hold any meaning).

### Execution

You have to select initial stars (the initial pieces of the puzzle) by
prefixing them with a `@` symbol as in:
```
X1, f(X1);
+a(X2,Y2);
@-h(f(X3, Y3)) +a(+f(X4), h(-f(X4)));
```

Those marked stars are fixed and put into an *interaction space*. The other
unmarked stars form a *reference constellation*. The LSC takes copies of stars
in the reference constellation and fires them to matching stars in the
interaction space until no possible interaction is left by following these
steps:
1. select a ray `ri` in a star `s` of the interaction space;
2. look for possible connections with rays `rj` belonging to stars in the
   reference constellation;
3. duplicate `s` so that there is exactly one copy of `s` in the interaction
   space for every `rj`;
4. replace every copy by its fusion `s <i,j> s'`, where `s'` is the star to
   which `rj` belongs.

The result of execution consists of all *neutral* stars that remain in the
interaction space, i.e. those without any polarized rays. Indeed, polarized
stars are ignored/removed because they correspond to *unfinished* (or stuck)
computations.

> [!NOTE]
> The interaction space can be seen as *linear* and the reference constellation
> as *non-linear*.

### Examples

Consider the following constellation:
```
+7(l:X) +7(r:X); 3(X) +8(l:X); @+8(r:X) 6(X);
-7(X) -8(X);
```
We have:
```
+8(r:X) 6(X) <0,1> -7(X) -8(X) == -7(r:X) 6(X)
```
Hence we obtain:
```
+7(l:X) +7(r:X); 3(X) +8(l:X); @-7(r:X) 6(X);
-7(X) -8(X);
```
We have:
```
-7(r:X) 6(X) <0,0> +7(l:X) +7(r:X) == +7(l:X) 6(X)
```
We obtain:
```
+7(l:X) +7(r:X); 3(X) +8(l:X); @+7(l:X) 6(X);
-7(X) -8(X);
```
We have:
```
+7(l:X) 6(X) <0,0> -7(X) -8(X) == -8(l:X) 6(X)
```
We obtain:
```
+7(l:X) +7(r:X); 3(X) +8(l:X); @-8(l:X) 6(X);
-7(X) -8(X);
```
We have:
```
-8(l:X) 6(X) <0,0> +8(l:X) 3(X) == 6(X) 3(X)
```
The result of the computation is
```
6(X) 3(X)
```

> [!NOTE]
> This computation corresponds to what we call cut-elimination for the proof
> structures of multiplicative linear logic.

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
