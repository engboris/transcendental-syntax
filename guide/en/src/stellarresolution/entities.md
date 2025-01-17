# Stars and Constellations

## Rays

The language of stellar resolution extends the notion of terms with the concept
of *rays*. A ray is a term where function symbols are polarized with:

- `+` (positive polarity);
- `-` (negative polarity);
- `$` (neutral polarity or absence of polarity).

The *compatibility* of rays follows the same rules as term unification,
except:
- instead of requiring equality `f = g` of function symbols when
`f(t1, ..., tn)` is confronted with `g(u1, ..., un)`, we require `f` and `g` to have opposite polarities (`+` versus `-`);
symbols without polarity cannot interact.

For example:
- `+f(X)` and `-f($h($a))` are compatible with `{X:=$h($a)}`;
- `$f(X)` and `$f($h($a))` are incompatible;
- `+f(X)` and `+f($h($a))` are incompatible;
- `+f(+h(X))` and `-f(-h($a))` are compatible with `{X:=$a}`;
- `+f(+h(X))` and `-f(-h(+a))` are compatible with `{X:=+a}`.

## Stars

With rays, we can form *stars*. These are unordered collections of rays:

```
+f(X) -f($h($a)) +f(+h(X))
```

The empty star is denoted as `[]`.

## Constellations

*Constellations* are unordered sequences of stars separated by the `;` symbol and
ending with a `.`:

```
+f(X) X; +f(+h(X) $a $f($b)).
```

The empty constellation is denoted as `{}`.

Constellations are, in fact, the smallest objects we can manipulate. They are
the ones that can be executed in the same way programs are executed.
