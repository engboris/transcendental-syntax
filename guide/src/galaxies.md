# Galaxies

Le langage Stellogen ajoute à la résolution stellaire une entité appelée
*galaxie*.

Une galaxie est soit une constellation soit une structure avec des champs
nommés contenant d'autres galaxies.

Plus généralement, Stellogen manipule en réalité des galaxies plutôt que
des constellations (qui sont des cas particulies de galaxies).

En Stellogen, "tout est galaxie" de la même manière que tout est objet
dans des langages de programmation comme *Smalltalk* ou *Ruby*.

On définit les galaxies avec des blocs `galaxy ... end` contenant une
série d'étiquettes `label:` suivit de la galaxie associée :

```
g = galaxy
  test1: +f($a) $ok.
  test2: +f($b) $ok.
end
```

On accède ensuite aux champs d'une galaxie avec `->` :

```
show g->test1.
show g->test2.
```
