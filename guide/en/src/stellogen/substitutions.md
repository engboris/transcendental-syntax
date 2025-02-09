# Substitutions

Substitutions are expressions of the form `[... => ...]` replacing an entity
by another.

## Variables

Variables can be replaced by any other ray:

```
show-exec (+f(X))[X=>Y].
show-exec (+f(X))[X=>+a(X)].
```

## Function symbols

Function symbols can be replaced by other function symbols:

```
show-exec (+f(X))[+f=>+g].
show-exec (+f(X))[+f=>f].
```

We can also omit the left or right part of `=>` to add or remove a head symbol:

```
show-exec (+f(X); f(X))[=>+a].
show-exec (+f(X); f(X))[=>a].
show-exec (+f(X); f(X))[+f=>].
```

## Tokens and galactic replacement

Galaxy expressions can contain special variables such
as `#1`, `#2` or `#variable`.

These are holes named *tokens* that can be replaced by another
galaxy:

```
show-exec (#1 #2)[#1=>+f(X) X][#2=>-f(a)].
```

This allows, notably, to write parametrized galaxies.
