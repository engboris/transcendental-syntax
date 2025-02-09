# Etoiles et constellations

## Rayons

Le langage de *résolution stellaire* étend la notion de terme avec la notion
de *rayon*. Un *rayon* est un terme où les symboles de fonction sont polarisés
avec :
- `+` (polarité positive);
- `-` (polarité négative);
- rien (polarité nulle ou absence de polarité).

La *compatibilité* entre les rayons suit les mêmes règles que l'unification
des termes sauf que :
- au lieu de demander l'égalité `f = g` des symboles de fonction lorsque
`f(t1, ..., tn)` est confronté à `g(u1, ..., un)`, on demande que `f` et `g`
aient une polarité opposée (`+` contre `-`);
- les symboles sans polarités ne peuvent pas interagir.

Par exemple :
- `+f(X)` et `-f(h(a))` sont compatibles avec `{X:=h(a)}`;
- `f(X)` et `f(h(a))` sont incompatibles;
- `+f(X)` et `+f(h(a))` sont incompatibles;
- `+f(+h(X))` et `-f(-h(a))` sont compatibles avec `{X:=a}`;
- `+f(+h(X))` et `-f(-h(+a))` sont compatibles avec `{X:=+a}`.

### Chaînes de caractère

Stellogen permet aussi de définir des constantes spéciales représentant des
chaînes de caractères :

```
"this is a string literal"
```

### Séquences

Il est possible d'utiliser un symbole infixe spécial `:` comme dans :

```
+w(0:1:0:1:e).
```

Il est possible de le parenthéser pour préciser la priorité (à droite par
défaut) :

```
+w((0:(1:(0:(1:e))))).
+w((((0:1):0):1):e).
```

## Etoiles

Avec les rayons, nous pouvons former des *étoiles*. Ce sont des collections
non ordonnées de rayons qui peuvent être entourées de crochets :

```
+f(X) -f(h(a)) +f(+h(X))
```

```
[+f(X) -f(h(a)) +f(+h(X))]
```

L'étoile vide est notée `[]`.

## Constellations

Les *constellations* sont des séquences non ordonnées d'étoiles séparées
par le symbole `;` et se terminant par un `.` :

```
+f(X) X; +f(+h(X) a f(b)).
```

Elles peuvent être entourées d'accolades :

```
{ +f(X) X; +f(+h(X) a f(b)) }.
```

Les variables sont locales à leur étoile. Cela peut être rendu explicite ainsi :

```
+f(X1) X1; +f(+h(X2) a f(b)).
```

La constellation vide est notée `{}`.

Les constellations sont en fait les plus petits objets que nous pourront
manipuler. C'est elles qui pourront être *exécutées* comme on exécute
un programme.
