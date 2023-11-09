# Large Star Collider

The Large Star Collider (LSC) is an implementation of the stellar resolution model introduced in Eng's thesis [1]. The stellar resolution is a model of computation based on Robinson's first order resolution with disjunctive clauses, which is used in logic programming. In this model, we compute with independent agents locally connecting which each other, forming a structure and propagating information by term unification [2]. It can compared to the computation of tile systems (Wang tiles, abstract tile assembly systems etc).

A **ray** is a first-order term
```
r := X | f(r1, ..., rn) 
```
where `f` is a function symbol which can be prefixed by a symbol `+` or `-` called *polarity*. A useful symbol is the infix binary symbol `.` which is right-associative (meaning that `a . b . c` stands for `a . (b . c)`). The symbol `.` is especially useful to represent sequences of characters (for instance, words used as input for automata).

Two rays containing polarised function symbols are compatible when they are unifiable (we consider the Martelli-Montanari unification algorithm in our program) knowing that identical function symbols with opposite polarity are considered equal (usually, only equal function symbols are considered).

A **star** is a finite non-ordered sequence of rays. It corresponds to disjunctive clauses in resolution logic.
```
[r1, ..., rn]
```
Stars are able to interact which each other along compatible rays by using Robinson's resolution rule. For instance, `[X, -f(X)]` and `[+f(a)]` can be connected along the symbol `f` and this connexion yields the result `[a]`. This operation is called *fusion*. It can be understood as a contrainst resolution between terms.

A **constellation** is a (potentially infinite) non-ordered sequence of stars (written as a sum of stars with the symbol `+`). They correspond to programs are written between braces `{` and `}`.
```
{ [r11, ..., r1n] + ... + [rn1, ..., rnm] }
```

What is executed are not constellation directly by **interaction configuration** which are expressions :
```
<constellation> |- <constellation>
```
The constellation on the left of `|-` is the *reference constellation* and the constellation on the right is the *interaction space*. The idea of the execution is that the interaction space is a "working space" in which some initial stars are present. Rays of those initial stars will interact (by fusion) with copies of stars from the reference constellation but also from the stars the selected rays come from.
- In order to work with automata, the reference constellation is a representation of the automata and the interaction space only contains the encoding of a word.
- For logic programs (such as in Prolog), we have the knowledge base on one side and the query on the other.
- For the proof-structures of multiplicative linear logic, we start with a star containing a free rays (the initial port of the Interactive Abstract Machine) in the interaction space and the other rays are in the reference constellation.

## Use

Building the project

```
dune build
```

```
dune exec lsc [-noloops] <inputfile>
```
where `-noloops` forbids trivial equations `X=X` during computation. This equation usually yields trivial loops linking two rays of a same star. This is something which can be unwanted in some cases.

## Examples

Some example files with the `.stellar` extension in `/examples` are ready to be executed. Below, some explanations of how to create other examples are given. In Eng's thesis, ways to work with other models of computation is a simple way are provided (Turing machines, pushdown automata, transducers, alternating automata etc).

### Constructing logic programs

Facts are stars `[+p(t1, ..., tn)]` and inference rules `P(t11, ..., t1n), ... P(tn1, ..., tnm) => P(u1, ..., uk)` are stars `[-p(t11, ..., t1n), ..., -p(tn1, ..., tnm), +p(u1, ..., uk)]` where negative rays are inputs (hypotheses) and the only positive ray is the output (conclusion).

Queries are stars `[+q(v1, ..., vl), X1, ..., Xp]` where `+q(v1, ..., vl)` corresponds to the query and `X1, ..., Xp` are variables occurring in the query that we would like to display in the result.

### Constructing finite automata

The encoding of a finite automata must include the following stars:
- `[-i(W), +a(W, q0)]` encoding the initial state (where `q0` can be replaced by any other name);
- `[-a(e, qf), accept]` encoding the accepting/final state (where `qf` can be replaced by any other name and `e` represents the empty word).

Each transition from a state `q1` to another state `q2` along the character `a` is encoded by a star:
```
[-a(a . W, q1), +a(W, q2)]
```

Words are encoded by sequences of characters separated by the binary symbol `.` and ending with `e`. For instance, `0 . 0 . 1 . e`, `e` or `1 . b . c . e` encode words.

Example with automata in the reference constellation and an input word in the interaction space:

```
{
	[-i(W), +a(W, q0)] +
	[-a(e, q2), accept] +
	[-a(0 . W, q0), +a(W, q0)] +
	[-a(1 . W, q0), +a(W, q0)] +
	[-a(0 . W, q0), +a(W, q1)] +
	[-a(0 . W, q1), +a(W, q2)]
}
|-
{
	[+i(0 . 0 . 0 . e)]
} 
```

### Constructing proof-structures of multiplicative linear logic

It is recommended to follow the method suggested in Eng's thesis. Each axiom becomes a binary star containing the translation of its atoms.

The translation of an atom `a` accessible from a conclusion `c` is given by a ray `+c(t)` where `t` is a sequence of symbols `l` (left) and `r` (right) separated by the binary symbol `.` and ending with the variable `X`. The idea is to encode the path from `c` to `a` by sequence of directions in the proof-structure.

For instance, if from a conclusion `c`, we need to go up by going left two times and right once in order to reach `a`, the translation of `a` will be `+c(l.l.r.X)`.

A cut connecting the conclusions `c1` and `c2` is simply encoded by a star `[-c1(X), -c2(X)]`.

Since proof-structures can be traversed by starting from any free atom, it is sufficient to put a star with a free (even unpolarised) ray in the interaction space and put the other stars in the reference constellation.

## References

- [1] [An exegesis of transcendental syntax. Eng.](https://hal.science/tel-04179276v1)
- [2] Term Rewriting and All That. Baader, Franz.
