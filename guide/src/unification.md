# Unification de termes

## Principe

En résolution stellaire, un *rayon* est soit :
- une *variable* notée en majuscules et pouvant contenir `_` ou des
chiffres. Comme `X`, `X10` ou encore `VAR_55`;
- un *symbole de fonction* préfixé de `+` (polarité positive), `-` (polarité
négative) ou de `$` (polarité nulle ou absence de polarité) possiblement
appliqué à une séquence ordonnée d'autres rayons "arguments" écrits entre
parenthèses.

Pour rendre l'écriture plus lisible, il existe un symbole binaire `:` infixe
nous permettant d'écrire `$a:X` à la place de `:($a X)` ou encore `$cons($a X)`.

> **Exemples de rayons.** `$f(X)`, `+f(-h(X $a))`, `$s`, `+list($a $b $c)`, `+list($a:$b:$c:$nil)`.

Dans la théorie de l'unification de termes classique, on dit que deux termes
sont *unifiables* lorsqu'il existe une substitution des variables de telle
sorte à les rendre égaux.
Par exemple, `f(X)` et `f(h(Y))` sont unifiables avec la substitution
`{X:=h(Y)}` remplaçant `X` par `h(Y)`.

Les substitutions qui nous intéressent sont celles qui sont les plus générales.
Nous aurions pu considérer la substitution `{X:=h(c(a)); Y:={c(a)}`, tout aussi
valide mais inutilement précise.

Dans la même idée, en résolution stellaire, nous disons que deux rayons sont
*compatibles* lorsque
 leur terme sous-jacent (obtenu par oubli des polarités) sont unifiables mais
nous voulons aussi que des symboles de fonctions de polarités opposées se
rencontrent (au lieu de considérer des symboles identiques):

- `+f(X)` et `-f($h($a))` sont compatibles avec `{X:=$h($a)}`;
- `$f(X)` et `$f($h($a))` sont incompatibles;
- `+f(X)` et `+f($h($a))` sont incompatibles;
- `+f(+h(X))` et `-f(-h($a))` sont compatibles avec `{X:=$a}`;
- `+f(+h(X))` et `-f(-h(+a))` sont compatibles avec `{X:=+a}`.

## Entités élémentaires de résolution stellaire

En résolution stellaire, nous avons :
- les rayons;
- les *étoiles* qui sont des séquences non ordonnées de rayons comme par
exemple `+f(X) X` ou `+f(+h(X)) $a $f($b)`;
- les *constellations* qui sont des séquences non ordonnées d'étoiles séparées
par le symbole `;` et se terminant par un `.`, comme par exemple
`+f(X) X; +f(+h(X) $a $f($b)).`.

L'étoile vide est notée `[]` et la constellation vide `{}`.

Les constellations sont en fait les plus petits objets que nous pourront
manipuler. C'est elles qui pourront être *exécutées*.
