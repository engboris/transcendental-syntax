# Substitutions

Les substitutions sont des expressions de la forme `[... => ...]` remplaçant
une entité par une autre.

## Variables

On peut remplacer des variables par n'importe quel rayon :

```
print (+f(X))[X=>Y].
print (+f(X))[X=>+a(X)].
```

## Symboles de fonction

On peut remplacer les symboles de fonctions par d'autres symboles
de fonction :

```
print (+f(X))[+f=>+g].
print (+f(X))[+f=>$f].
```

On peut aussi omettre la partie gauche ou droite de `=>` pour ajouter
ou retirer un symbole de tête :

```
print (+f(X); $f(X))[=>+a].
print (+f(X); $f(X))[=>$a].
print (+f(X); $f(X))[+f=>].
```

## Tokens et remplacement galactique

Les expressions de galaxies peuvent contenir des constellations vides
nommées par des identifiants comme `{1}`, `{2}`, `{a}` ou encore `{variable}`.

Ce sont des trous appelés *tokens* qui peuvent être remplacés par une autre
galaxie :

```
print ({1} {2})[1=>+f(X) X][2=>-f($a)].
```

Cela permet notamment d'écrire des galaxies paramétriques.
