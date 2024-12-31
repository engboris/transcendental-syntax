# Définir des constellations

## Commentaires

Les commentaires commencent par `'` et sont écrits entre `'''` pour
les commentaires multi-lignes. Ils sont ignorés pendant l'exécution.

## Définitions statiques

On peut nommer des constellations que l'on écrit directement. Les identifiants
suivent les mêmes règles que pour les symboles de fonction des rayons.

```
x = +a; -a $b.
z = -f(X).
```

On peut aussi choisir d'associer un identifiant à un autre :

```
y = x.
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

> Les définitions statiques correspondent à la notion "d'objet-preuve".
> en correspondance de Curry-Howard.

## Affichage

Pour afficher des constellations, vous pouvez utiliser la commande `show`
suivit d'une constellation :

```
show +a; -a $b.
```

La commande `show` n'exécute pas les constellations. Si vous voulez vraiment
exécuter la constellation et afficher son résultat, utilisez la commande
`print` :

```
print +a; -a $b.
```

## Focus

Si on souhaite que des étoiles soient initiales, il faut les préfixer avec le
symbole `@` (focus) :

```
x = @+a; -a $b.
z = @-f(X).
```

Les étoiles initiales sont placées dans un espace de travail et sont sujettes
à l'interaction par fusion avec des copies des autres étoiles.

On peut aussi mettre le focus sur toutes les étoiles d'une constellation en
la préfixant aussi avec `@` :


```
x = +a; -a $b.
z = -f(X).
union1 = (@x) z.
```

## Processus de construction

On peut enchaîner des constellations avec l'expression `process ... end` :

```
c = process
  +n0($0).
  -n0(X) +n1($s(X)).
  -n1(X) +n2($s(X)).
end
```

Cet enchaînement part de la première constellation `+n0($0)` considérée comme
initiale. La constellation suivante interagit ensuite avec la précédente. On
a donc une chaîne d'interaction avec focus complet sur le résultat précédent.

C'est comme si nous faisions le calcul suivant :

```
@+n0($0);
-n0(X) +n1($s(X)).
```

donnant

```
+n1($s($0)).
```

puis
```
@+n1($s($0));
-n1(X) +n2($s(X)).
```

donnant

```
+n2($s($s($0))).
```

> C'est ce qui correspond aux tactiques dans des assistants de preuve comme Coq
et que l'on pourrait assimiler aux programmes impératifs qui altèrent des
représentation d'état (mémoire par exemple).

> Les constructions dynamiques correspondent à la notion de "processus-preuve"
chez Boris Eng ou de "proof-trace" chez Pablo Donato. Les processus-preuves
construisent des objet-preuves (constellations).

# Nettoyage

Dans le résultat d'une exécution, si l'on représente les résultats par des
rayons à polarité nulle, alors les étoiles contenant des rayons polarisés
peuvent être interprétés comme des calculs non terminés qu'il pourrait être
effacés.

Pour cela, dans les processus de constructions, nous pouvons utiliser
l'expression spéciale `clean` :

```
c = process
  +n0($0).
  -n0(X) +n1($s(X)).
  -n1(X) +n2($s(X)).
  -n2(X) $result(X); -n2(X) +n3(X).
  clean.
end

print c.
```

Nous avons utilisé un rayon `+n3(X)` pour poursuivre des calculs
si nous souhaitons. Le résultat est stocké dans `$result(X)`.
Mais si nous souhaitons seulement conserver le résultat et retirer toute
autre possibilité de calcul alors on peut utiliser `clean`.
