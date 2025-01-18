# Introduction

There are multiple ways to encode objects:

- **Algebraic encodings**, which assign meaning to function symbols. Objects are
encoded as rays;
- **interactive encodings**, which align more closely with the philosophy of
transcendental syntax. Objects are encoded as constellations. Specifically,
the dynamics of objects are encoded in the dependencies between rays, and
their meaning is provided by their types.

## Algebraic Encoding

Prolog uses algebraic encodings. For example, a pair could be represented by a
ray `+pair(X Y)`. The components are other terms. Functions acting on pairs are
stars containing a ray like `-pair(X Y)` or using function symbols to represent
predicates/properties, such as `+exchange(+pair(X Y) +pair(Y X))`.

## Interactive Encoding

In an interactive encoding (closer to proof theory, particularly to the theory
of proof nets in linear logic), each component is represented by a constellation.

There are two types of pairs:

- **Tensor product**, where we have a union of two disjoint constellations.
Projections may not be defined in this case.
- **Cartesian product**, where something distinguishes each component, and we
have the ability to extract a specific component (left or right).

The difference between these two types of encoding is still under exploration.
I welcome feedback if anyone has insights. I believe this distinction has
implications for expressiveness and ease of type manipulation.

## Special Symbols

Stellogen defines a binary infix symbol `:` that is right-associative, allowing
us to write `$a:X` instead of `:($a X)` or `$cons($a X)`.

This enables readable concatenation of symbols, for example:

```
+f($a:$b:$c:$e).
```
