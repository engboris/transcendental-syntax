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
5. répéter jusqu'à qu'il n'y a plus aucune interaction possible l'espace
d'états.

## Focus

Les étoiles d'état sont préfixées par un symbole `@` :

```
@+a b; [-c d].
```

```
+a b; [@-c d].
```

## Exemple

Considérons l'exécution de la constellation suivante :

```
@+a(0(1(e)) q0);
-a(e q2) accept;
-a(0(W) q0) +a(W q0);
-a(0(W) q0) +a(W q1);
-a(1(W) q0) +a(W q0);
-a(0(W) q1) +a(W q2).
```

Pour l'exemple, on entoure par `>>` et `<<` les rayons sélectionnés. Nous avons
donc l'étapes suivante :

```
-a(e q2) accept;
-a(0(W) q0) +a(W q0);
-a(0(W) q0) +a(W q1);
-a(1(W) q0) +a(W q0);
-a(0(W) q1) +a(W q2);
@+a(0(1(e)) q0).
```

Nous avons la séparation suivante :

```
-a(e q2) accept;
-a(0(W) q0) +a(W q0);
-a(0(W) q0) +a(W q1);
-a(1(W) q0) +a(W q0);
-a(0(W) q1) +a(W q2)
|-
+a(0(1(e)) q0)
```

Sélectionnons le premier rayon de la première étoile :

```
>>-a(e q2)<< accept;
-a(0(W) q0) +a(W q0);
-a(0(W) q0) +a(W q1);
-a(1(W) q0) +a(W q0);
-a(0(W) q1) +a(W q2)
|-
+a(0(1(e)) q0)
```

Il ne peut pas se connecter à `+a(0(1(e)) q0)` car le premier argument `e` est
incompatible avec `0(1(e))`. Cependant, il peut interagir avec
les deux étoiles suivantes (mais pas la dernière à cause d'une
incompatibilité entre `q0` et `q1`).
Nous effectuons une duplication et fusion suivante entre :

```
-a(0(W) q0) +a(W q0);
-a(0(W) q0) +a(W q1);
```

et

```
+a(0(1(e)) q0)
```

donnant la substitution `{W:=1(e)}` et le résultat :

```
+a(1(e) q0);
+a(1(e) q1)
```

Nous obtenons donc l'étape suivante :

```
-a(e q2) accept;
-a(0(W) q0) +a(W q0);
-a(0(W) q0) +a(W q1);
-a(1(W) q0) +a(W q0);
-a(0(W) q1) +a(W q2)
|-
+a(1(e) q0);
+a(1(e) q1)
```

La seconde étoile d'état `+a(1(e) q1)` ne peut interagir avec aucune
étoile d'action. Cependant on peut se focaliser sur `+a(1(e) q0)`.

```
-a(e q2) accept;
-a(0(W) q0) +a(W q0);
-a(0(W) q0) +a(W q1);
-a(1(W) q0) +a(W q0);
-a(0(W) q1) +a(W q2)
|-
>>+a(1(e) q0)<<;
+a(1(e) q1)
```

Il peut se connecter à `-a(1(W) q0)` avec comme substitution
`{W:=e}` :

```
-a(e q2) accept;
-a(0(W) q0) +a(W q0);
-a(0(W) q0) +a(W q1);
-a(1(W) q0) +a(W q0);
-a(0(W) q1) +a(W q2)
|-
+a(e q0);
+a(1(e) q1)
```

Plus aucune interaction n'est possible.
Le résultat de l'exécution est donc :

```
+a(e q0);
+a(1(e) q1)
```
