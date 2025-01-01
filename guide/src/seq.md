# Séquences

# Cas algébrique

## Séquences fixes

```
+seq($a $b $c $d).
```

On peut récupérer le premier élément avec :

```
head = +head(-seq(X1 X2 X3 X4) X1).
query = -head(+seq($1 $2 $3 $4) R) R.
print (query head).
```

## Pile de constantes

```
+list($a($b($c($e)))).
```

On peut ajouter ou retirer un élément en tête avec :

```
l = +list($a($b($c($e)))).
print process
  l.
  'push
    -list(X) +tmp($new(X)).
    -tmp(X) +list(X).
  'pop
    -list($new(X)) +list(X).
end
```

> **Remarque.** On ne peut pas raisonner sur un symbole de fonction
quelconque. On ne peut donc seulement empiler et dépiler des symboles
spécifiques. Pour résoudre ce problème, il faut utiliser les symboles
de fonction comme constructeurs et non valeurs.

## Listes générales

On peut imaginer de nombreuses représentations équivalentes en utilisant
les symboles de fonction pour concaténer les éléments ensemble.

```
+list($a:$b:$c:$d:$e).
+list($cons($a, $cons($b, $cons($c, $cons($d, $e))))).
+cons($a, +cons($b, +cons($c, +cons($d, $e)))).
```

On peut ajouter et retirer des éléments de la manière suivante :

```
l = +list($a:$b:$c:$d:$e).
print process
  l.
  'push
    -list(X) +tmp($new:X).
    -tmp(X) +list(X).
  'pop
    -list(C:X) +list(X).
end
```

En suivant les principes de programmation logique on peut vérifier si une
liste est vide :

```
empty? = +empty?($e).

print empty? @-empty?($e) $ok.
print empty? @-empty?($1:$e) $ok.
```

Concaténer deux listes :

```
append =
  +append($e L L);
  -append(T L R) +append(H:T L H:R).

print append @-append($a:$b:$e $c:$d:$e R) R.
```

Inverser une liste :

```
rev =
  +revacc($e ACC ACC);
  -revacc(T H:ACC R) +revacc(H:T ACC R);
  -revacc(L $e R) +rev(L R).

print rev @-rev($a:$b:$c:$d:$e R) R.
```

Appliquer une fonction sur tous les éléments d'une liste :

```
map =
  +map(X $e $e);
  -funcall(F H FH) -map(F T R) +map(F H:T FH:R).

print
  map
  +funcall($f X $f(X));
  @-map($f $a:$b:$c:$d:$e R) R.
```

# Cas interactif

(TODO)
