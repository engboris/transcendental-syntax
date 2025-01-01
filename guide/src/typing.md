# Typage

Le typage en Stellogen utilise les principes de syntaxe transcendantale
où les types sont définis comme des ensembles de tests elles-mêmes définies
avec des constellations. La vérification de type implique le passage de tous
les tests associés à un type.

Conformément à la correspondance de Curry-Howard, les types peuvent être vues
comme des formules ou spécifications. On pourrait aussi étendre cela à la
proposition de Thomas Seiller de voir les algorithmes comme des spécifications
plus sophistiquées.

## Checkers

Tout d'abord il faut définir des *checkers* qui sont des galaxies d'une
certaine forme contenant :
- un champ `interaction` contenant nécessairement un token `{tested}` et un
autre token `{tested}`;
- un champ `expect`.

Par exemple :

```
checker = galaxy
  interaction: {tested} {test}.
  expect: $ok.
end
```

Le checker est un "juge" qui définit comment une constellation représentant
un test interagit avec une constellation représentant un élément testé.
Le champ `expect` est la constellation attendue comme résultat de l'interaction
décrite.

## Typage par test

Les *types* sont ensuite soit des constellations (s'il n'y a qu'un test)
ou alors des galaxies où chaque champ représente un test à faire passer.

Voici un type avec un unique test pour une représentation naïve des entiers
naturels :

```
nat =
  -nat($0) $ok;
  -nat($s(N)) +nat(N).
```

On peut ensuite écrire des assertions de typage de la forme `x :: t [c]` où
`x` est l'élément testé, `t` est le type (définissant des tests) et `c` et le
checker.

```
0 :: nat [checker]
0 = +nat($0).

1 :: nat [checker]
1 = +nat($s($0)).
```
