# Substitutions

Substitutions are expressions of the form `[... => ...]` replacing an entity
by another.

## Variables

Variables can be replaced by any other ray:

```
print (+f(X))[X=>Y].
print (+f(X))[X=>+a(X)].
```

## Function symbols

Function symbols can be replaced by other function symbols:

```print (+f(X))[+f=>+g].
print (+f(X))[+f=>$f].
```

We can also omit the left or right part of `=>` to add or remove a head symbol:

```
print (+f(X); $f(X))[=>+a].
print (+f(X); $f(X))[=>$a].
print (+f(X); $f(X))[+f=>].
```

## Tokens and galactic replacement

Galaxy expressions can contain empty constellations named by identifiers such
as `{1}`, `{2}`, `{3}` or `{variable}`.

These are holes named *tokens* that can be replaced by another
galaxy:

```
print ({1} {2})[1=>+f(X) X][2=>-f($a)].
```

This allows, notably, to write parametrized galaxies.
