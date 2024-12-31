# Exécution de constellations

## Fusion d'étoiles

Les étoiles interagissent entre elles par une opération appelée *fusion* (que l'on
pourrait qualifier de protocole d'interaction), en utilisant le principe de
la règle de *résolution de Robinson*. Pour expliquer la théorie, on définit un
opérateur `<i,j>` connectant le `i`ème rayon d'une étoile au `j`ème rayon d'une
autre étoile.

La fusion est définie ainsi pour deux rayons compatibles `r` et `r'`:
```
r r1 ... rk <0,0> r' r1' ... rk' == theta(r1) ... theta(rk) theta(r1') ... theta(rk')
```

où `theta` est la substitution la plus générale induite par `r` et `r'`.

Remarquez que:
- `r` et `r'` sont annihilées pendant l'interaction;
- leurs deux étoiles fusionnent;
- la substitution obtenue par résolution du conflit entre `r` et `r'` est
propagée aux rayons adjacents.

> **Exemple.** Dans un fichier, écrire puis exécuter le code suivant :
> ```
> print X +f(X); -f($a).
> ```
> Nous obtenons `a` car `+f(X)` et `-f($a)` ont interagi ensemble puis se
> sont annihilé pour mettre à jour leurs voisins avec la substitution `{X:=$a}`.
> Le résultat est donc `X{X:=a}` soit `a`.

> Cette opération de fusion correspond à la règle de compure pour la logique
du premier ordre. Cependant, la différence ici est que nous sommes dans un
cadre "alogique" (nos symboles ne portent aucun sens logique).

## Exécution

Cela marche à peu près comme pour la résolution d'un puzzle ! Vous avez une
constellation faites de plusieurs étoiles. Choisissez des étoiles initiales
puis des copies des autres étoiles seront jetées dessus pour interagir par
fusion. L'opération continue jusqu'à qu'il n'y ait plus d'interactions
possibles.
La constellation obtenue à la fin est le résultat de l'exécution.

Plus formellement, soit `I` l'ensemble des *étoiles initiales* (à voir comme
une sorte d'espace de travail ou d'interaction) et `R` le
reste appelé *ensemble des étoiles de référence*. L'exécution procèe de la
façon suivante :
1. selectionner un rayon `ri` d'une étoile `s` de `I`;
2. chercher toutes les connexions possibles avec des rayons `rj` d'étoiles `s'`
   de `R`;
3. dupliquer `s` dans `I` pour chaque `rj` trouvé;
4. remplacer chaque copie de `s` par la fusion `s <i,j> s'`;
5. répeter jusqu'à qu'il n'y a plus aucune interaction possible dans `I`.

## Exemple

Considérons l'exécution de la constellation suivante où l'unique étoile
initiale est préfixée par `@`:
```
+7($l:X) +7($r:X); $3(X) +8($l:X); @+8($r:X) $6(X);
-7(X) -8(X);
```

On sépare la constellation en constellation de référence (à gauche de `|-` et
en espace d'interaction (à droite de `|-`).
Pour l'exemple, on préfixe par `>>` les rayons sélectionnés. Nous avons donc
les étapes suivantes :
```
+7($l:X) +7($r:X); $3(X) +8($l:X); -7(X) >>-8(X) |- >>+8($r:X) $6(X);
```

```
+7($l:X) +7($r:X); $3(X) +8($l:X); -7(X) -8(X) |- -7($r:X) $6(X);
```

```
+7($l:X) >>+7($r:X); $3(X) +8($l:X); -7(X) -8(X) |- >>-7($r:X) $6(X);
```

```
+7($l:X) +7($r:X); $3(X) +8($l:X); -7(X) -8(X) |- +7($l:X) $6(X);
```

```
+7($l:X) +7($r:X); $3(X) +8($l:X); >>-7(X) -8(X) |- >>+7($l:X) $6(X);
```

```
+7($l:X) +7($r:X); $3(X) +8($l:X); -7(X) -8(X) |- -8($l:X) $6(X);
```

```
+7($l:X) +7($r:X); $3(X) >>+8($l:X); -7(X) -8(X) |- >>-8($l:X) $6(X);
```

```
+7($l:X) +7($r:X); $3(X) +8($l:X); -7(X) -8(X) |- $3(X) $6(X);
```

Le résultat du calcul est une constellation contenant uniquement l'étoile
`$3(X) $6(X);`.
