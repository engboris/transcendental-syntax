# Introduction

Il existe plusieurs manières d'encoder des objets :
- les encodages *algébriques* qui associent un sens aux symboles de fonction. Les objets sont donc encodés en tant que rayons;
- les encodages *interactifs*, plus proche de la philosophie de la syntaxe transcendantale. Les objets sont encodés en tant que constellations. En particulier, la dynamique des objets est encodée dans les dépendances entre les rayons. Le sens des objets est donné par les types.

## Encodage algébrique

Le langage Prolog utilise des encodages algébriques. Une paire pourra par
exemple être représentée par un rayon `+pair(X Y)`. Les composantes sont donc
d'autres termes. Les fonctions sur les paires sont des étoiles contenant un
rayon `-pair(X Y)` ou utilisant des symboles de fonction représentant des
prédicats/propriétés comme `+exchange(+pair(X Y) +pair(Y X))`.

## Encodage interactif

Dans un encodage interactif (plus proche de la théorie de la démonstration
et notamment de la théorie des réseaux de preuve de la logique linéaire),
chaque composante est donnée par une constellation.

Nous avons deux types de paires :
- le *tenseur* où nous avons une union entre deux constellations disjointes.
Nous n'avons pas forcément de fonction de projection dans ce cas;
- le *produit cartésien* où quelque chose distingue chaque composantes et où nous aurions la possibilité d'extraire une composante en particulier (gauche ou droite).

> La différence entre les deux types d'encodages est encore en cours de
réflexion, je suis preneur si quelqu'un a un avis. Je pense que cela a des
conséquences en expressivité et facilité de manipulation des types.

## Symboles spéciaux

Stellogen définit un symbole binaire `:` infixe et associatif à droite nous
permettant d'écrire `a:X` à la place de `:(a X)` ou encore `cons(a X)`.
Cela nous permet notamment de concaténer des symboles de façon lisible :

```
+f(a:b:c:e).
```
