# Galaxies

The Stellogen language adds to stellar resolution an entity named *galaxy*.

A galaxy is either a constellation or a structure with named fields containing
other galaxies.

More generally, Stellogen actually manipulates galaxies rather than
constellations (that are special cases of galaxy).

In Stellogen, "everything is galaxy" in the same way that everything is
object is programming languages like *Smalltalk* or *Ruby*.

Galaxies are defined with blocks `galaxy ... end` containing a series of labels
`label:` followed by the associated galaxy:

```
g = galaxy
  test1: +f($a) $ok.
`  test2: +f($b) $ok.
end
```

Fields of a galaxy are then accessed with `->`:

```
show g->test1.
show g->test2.
```

> This resembles the concept of a record in programming, except that when
galaxies are used, they are represented by their underlying constellation (by
forgetting the labels).
