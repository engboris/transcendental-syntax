# Définir des constellations

## Commentaires

Les commentaires commencent par `'` et sont écrits entre `'''` pour
les commentaires multi-lignes. Ils sont ignorés pendant l'exécution.

## Définitions statiques

On peut nommer des constellations que l'on écrit directement. Les identifiants
suivent les mêmes règles que pour les symboles de fonction des rayons.

Les constellations sont entourées d'accolades `{ ... }`.

```
w = { a }.
x = { +a; -a b }.
z = { -f(X) }.
```

On peut aussi choisir d'associer un identifiant à un autre :

```
y = x.
```

Les accolades autour des constellations peuvent être omises lorsqu'il
n'y a pas d'ambiguïté avec les identifiants :

```
w = { a }.
x = +a; -a b.
z = -f(X).
```

Comme pour l'application en programmation fonctionnelle, l'union de
constellations est notée avec un espacement :

```
union1 = x y z.
```

On peut aussi ajouter des parenthèses autour des expressions pour
plus de lisibilité ou pour éviter des ambiguïtés syntaxiques :

```
union1 = (x y) z.
```

Mais il faut noter que contrairement à la programmation fonctionnelle,
il n'y a pas d'ordre défini.

> Les définitions statiques correspondent à la notion "d'objet-preuve"
> dans la correspondance de Curry-Howard.

## Affichage

Pour afficher des constellations, vous pouvez utiliser la commande `show`
suivit d'une constellation :

```
show +a; -a b.
```

La commande `show` n'exécute pas les constellations. Si vous voulez vraiment
exécuter la constellation et afficher son résultat, utilisez la commande
`print` :

```
print +a; -a b.
```

## Focus

On peut mettre le focus sur toutes les étoiles d'une constellation en
la préfixant aussi avec `@` :

```
x = +a; -a b.
z = -f(X).
union1 = (@x) z.
```

## Processus de construction

On peut enchaîner des constellations avec l'expression `process ... end` :

```
c = process
  +n0(0).
  -n0(X) +n1(s(X)).
  -n1(X) +n2(s(X)).
end
```

Cet enchaînement part de la première constellation `+n0(0)` considérée comme
initiale. Chaque constellation suivante interagit ensuite avec le résultat
précédent. C'est comme si nous faisions le calcul suivant :

```
@+n0(0);
-n0(X) +n1(s(X)).
```

donnant

```
+n1(s(0)).
```

puis

```
@+n1(s(0));
-n1(X) +n2(s(X)).
```

donnant

```
+n2(s(s(0))).
```

> C'est ce qui correspond aux tactiques dans des assistants de preuve comme Coq
et que l'on pourrait assimiler aux programmes impératifs qui altèrent des
représentation d'état (mémoire par exemple).

> Les constructions dynamiques correspondent à la notion de "processus-preuve"
chez Boris Eng ou de "proof-trace" chez Pablo Donato. Les processus-preuves
construisent des objet-preuves (constellations).

# Arrêt de processus

Dans le résultat d'une exécution, si l'on représente les résultats par des
rayons à polarité nulle, alors les étoiles contenant des rayons polarisés
peuvent être interprétés comme des calculs non terminés qui pourraient être
effacés.

Pour cela, dans les processus de constructions, nous pouvons utiliser
l'expression spéciale `kill` :

```
c = process
  +n0(0).
  -n0(X) +n1(s(X)).
  -n1(X) +n2(s(X)).
  -n2(X) result(X); -n2(X) +n3(X).
  kill.
end

print c.
```

Nous avons utilisé un rayon `+n3(X)` pour poursuivre des calculs
si nous souhaitons. Le résultat est stocké dans `result(X)`.
Mais si nous souhaitons seulement conserver le résultat et retirer toute
autre possibilité de calcul alors on peut utiliser `kill`.

# Nettoyage de processus

Il arrive parfois que l'on se retrouve avec des étoiles vides `[]` dans
les processus. Il est possible de s'en débarrasser avec la commande `clean` :

```
print process
  +f(0).
  -f(X).
  clean.
end
```
