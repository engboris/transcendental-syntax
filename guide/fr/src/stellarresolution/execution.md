# Exécution de constellations

## Fusion d'étoiles

Les étoiles interagissent entre elles par une opération appelée *fusion* (que
l'on pourrait qualifier de protocole d'interaction), en utilisant le principe
de la règle de *résolution de Robinson*.

La fusion entre deux étoiles

```
r r1 ... rk
```

et

```
r' r1' ... rk'
```

le long de leurs rayons `r` et `r'` est définie par une nouvelle étoile :

```
theta(r1) ... theta(rk) theta(r1') ... theta(rk')
```

où `theta` est la substitution la plus générale induite par `r` et `r'`.

Remarquez que:
- `r` et `r'` sont annihilées pendant la fusion;
- les deux étoiles fusionnent;
- la substitution obtenue par résolution du conflit entre `r` et `r'` est
propagée aux rayons adjacents.

> **Exemple.** La fusion entre `X +f(X)` et `-f(a)` fait interagir `+f(X)`
> et `-f(a)` ensemble pour propager la substitution `{X:=a}` sur l'unique
> voisin `X`. Le résultat est donc `X{X:=a}` soit `a`.

> Cette opération de fusion correspond à la règle de coupure pour la logique
> du premier ordre (correspondant aussi à la règle de résolution). Cependant,
> la différence ici est que nous sommes dans un cadre "alogique" (nos objets
> ne portent aucun sens logique).

## Exécution

Cela marche à peu près comme pour la résolution d'un puzzle ou un jeu de
fléchettes. Vous avez une constellation faites de plusieurs étoiles.
Choisissez des *étoiles initiales*
puis des copies des autres étoiles seront jetées dessus pour interagir par
fusion. L'opération continue jusqu'à qu'il n'y ait plus d'interactions
possibles (saturation).
La constellation obtenue à la fin est le résultat de l'exécution.

Plus formellement, nous séparons une constellation en deux parties pour
l'exécuter :
- *l'espace d'états*, un espace d'étoiles qui seront cibles de l'interaction;
- *l'espace d'actions* qui sont des étoiles qui vont interagir avec
les étoiles de l'espace d'états.

On pourrait représenter cette séparation ainsi avec l'espace d'actions
à gauche et l'espace d'états à droite, séparées avec le symbole `|-` :

```
a1 ... an |- s1 ... sm
```

L'exécution procède de la façon suivante :
1. selectionner un rayon `r` d'une étoile d'état `s`;
2. chercher toutes les connexions possibles avec des rayons `r'` d'étoiles
d'action `a`;
3. dupliquer `s` à droite pour chaque tel rayon `r'` trouvé car il y a
plusieurs interactions possibles à satisfaire;
4. remplacer chaque copie de `s` par la fusion entre `a` et `s`;
5. répéter jusqu'à qu'il n'y a plus aucune interaction possible l'espace d'états.

## Exemple

Considérons l'exécution de la constellation suivante où l'unique étoile
initiale de l'espace d'état est préfixée par `@`:
```
+add(0 Y Y);
-add(X Y Z) +add(s(X) Y s(Z));
@-add(s(s(0)) s(s(0)) R) R.
```

Pour l'exemple, on entoure par `>>` et `<<` les rayons sélectionnés. Nous avons
donc les étapes suivantes :

```
+add(0 Y Y);
-add(X Y Z) +add(s(X) Y s(Z));
@-add(s(s(0)) s(s(0)) R) R.
```

Nous avons la séparation suivante :

```
+add(0 Y Y);
-add(X Y Z) +add(s(X) Y s(Z))
|-
-add(s(s(0)) s(s(0)) R) R
```

Sélectionnons le premier rayon :

```
+add(0 Y Y);
-add(X Y Z) +add(s(X) Y s(Z))
|-
>>-add(s(s(0))<< s(s(0)) R) R
```

Il ne peut pas se connecter à `+add(0 Y Y)` car le premier argument `0` est
incompatible avec `s(s(0))`. Cependant, il peut interagir avec
`+add(s(X) Y s(Z))`. Nous effectuons une fusion suivante entre

```
-add(X Y Z) +add(s(X) Y s(Z))
```

et

```
-add(s(s(0)) s(s(0)) R) R
```

donnant la substitution `{X:=s(0), Y:=s(s(0)), R:=s(Z)}` et le résultat :

```
-add(s(0) s(s(0)) Z) s(Z)
```

Nous obtenons donc l'étape suivante :


```
+add(0 Y Y);
-add(X Y Z) >>+add(s(X) Y s(Z))<<
|-
-add(s(0) s(s(0)) Z) s(Z)
```

Nous resélectinnons le premier rayon :

```
+add(0 Y Y);
-add(X Y Z) +add(s(X) Y s(Z))
|-
>>-add(s(0) s(s(0)) Z)<< s(Z)
```

Il peut se connecter à `+add(s(X) Y s(Z))` avec comme substitution
`{X:=0, Y:=s(s(0)), Z:=s(Z')}` :

```
+add(0 Y Y);
-add(X Y Z) +add(s(X) Y s(Z))
|-
-add(0 s(s(0)) Z') s(s(Z'))
```

Nous sélectionnons le premier rayon :

```
+add(0 Y Y);
-add(X Y Z) +add(s(X) Y s(Z))
|-
>>-add(0 s(s(0)) Z')<< s(s(Z'))
```

Il ne peut interagir qu'avec la première étoile d'action `+add(0 Y Y)`, ce
qui nous donne :

```
+add(0 Y Y);
-add(X Y Z) +add(s(X) Y s(Z))
|-
s(s(s(s(0))))
```

Le résultat de l'exécution est donc :

```
s(s(s(s(0))))
```
