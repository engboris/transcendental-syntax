# Large Star Collider

La résolution stellaire est un modèle de calcul proche de la résolution du premier ordre de Robinson qui est utilisée en programmation logique. Ce programme est une réalisation en OCaml de ce modèle de résolution stellaire.

Un **rayon** est un terme du premier ordre 
```
r := X | f(r1, ..., rn) 
```
où `f` est un symbole de fonction qui peut être préfixé ou non d'une polarité `+` ou `-` (par exemple `+f` et `-f`). Dans ce programme, on pourra aussi utiliser le symbole de fonction binaire `.` qui est infixe et associatif à droite (c'est-à-dire qu'on écrit `a . b . c` pour signifier `a . (b . c)`). Ce symbole est très utile pour créer des séquences de caractères (par exemple pour les mots en entrée des automates).

Deux rayons qui contiennent des symboles polarisés peuvent être connectés lorsqu'ils sont unifiables sachant que les symboles de fonction identiques modulo inversion de polarité sont compatibles (habituellement, seuls les symboles égaux le sont).

Une **étoile** est une séquence de rayons qu'on peut considérer comme une clause dans un langage de programmation.
```
[r1, ..., rn]
```
Les étoiles sont capables d'interagir ensemble le long de rayons connectables par la règle de résolution de Robinson. Par exemple : `[X, -f(X)]` et `[+f(a)]` connectés ensemble le long du symbole `f` donne `[a]`. On appelle cette opération une étape de **fusion**. On peut voir cela comme une résolution de contraintes entre termes.


Une **constellation** est une union disjointe d'étoiles séparées par le symbole `+`. On peut considérer que les constellations sont des sortes de programmes dans ce modèle. Une constellation est délimitée par des accolades.
```
{ [r11, ..., r1n] + ... + [rn1, ..., rnm] }
```

Ce que l'on cherche à exécuter n'est pas une constellation mais un **espace d'interaction**. C'est une expression de la forme :
```
<constellation> |- <constellation>
```
La constellation à gauche de `|-` est la *constellation de référence* et la constellation de droite est *l'espace d'interaction*. L'idée de l'**exécution** est que l'espace d'interaction est une zone de travail où se trouve les étoiles initiales au départ. Ces étoiles initiales vont interagir par fusion avec des copies d'étoiles de la constellation de référence mais aussi de l'espace d'interaction.
- Pour travailler avec des automates, la constellation de référence est l'automate et l'espace d'interaction démarre avec l'encodage d'un mot.
- Avec des programmes logiques, on aura la base de connaissance d'un côté et la requête de l'autre.
- Avec les preuves de la logique linéaire, on aura la structure de preuve auquel on aura retiré une étoile contenant un atome libre pour la placer dans l'espace d'interaction. Les structures de preuves, contrairement aux automates et programmes logiques, peuvent être exécutés par n'importe quel point d'entrée. Plusieurs choix sont donc possibles.

## Compilation

```
make
```

Pour supprimer les fichiers de compilation et nettoyer le projet :

```
make clean
```

## Usage

Il faut simplement lancer l'exécutable `main`.

```
./main
```

Vous pouvez utiliser les commandes suivantes :
- `exit` pour quitter le programme (ou le mode interactif).
- `exec -f <filename>` pour exécuter l'espace d'interaction contenu dans le fichier de nom `<filename>`.
- `exec <intspace>` pour exécuter l'espace d'interaction `<intspace>`.
- `intmode` lance le mode interactif avec la constellation vide comme constellation initiale (voir section "Mode interactif").
- `intmode -f <filename>` lance le mode interactif avec la constellation définie dans `<filename>` (voir section "Mode interactif").
- `intmode <constellation>` lance le mode interactif avec la constellation `<constellation>` (voir section "Mode interactif").
- `disable-loops` interdit les équations de la forme `X=X` qui peuvent mener à des boucles triviales.
- `enable-loops` autorise les boucles triviales.

## Mode interactif

Le mode interactif est un mode ludique adapté aux grands et petits (âge minimum conseillé : 8 ans). Vous démarrez à partir de la constellation initiale vide `{}`. Toutes les constellations que vous écrivez vont interagir et mettre à jour votre constellation.

Petite astuce : si vous écrivez une constellation qui ne peut interagir avec aucune étoile, cela va simplement l'ajouter à la constellation. Cela permet de remplir petit à petit votre constellation.

## Exemples

Certains exemples avec l'extension `.stellar` sont déjà prêts à être exécutés. Ci-dessous, je présente quelques moyens de créer vos propres exemples. Dans mon manuscrit de thèse, vous retrouverez des méthodes pour réaliser de nombreux autres modèles comme des machines de Turing, automates à piles, transducteurs ou automates alternants de façon très simple.

### Programmes logiques

Les faits sont des étoiles `[+p(t1, ..., tn)]` et les règles d'inférences `P(t11, ..., t1n), ... P(tn1, ..., tnm) => P(u1, ..., uk)` sont des étoiles `[-p(t11, ..., t1n), ..., -p(tn1, ..., tnm), +p(u1, ..., uk)]` où les rayons négatifs sont des entrées (hypothèses) et le rayon positif la sortie (conclusion).

Les requêtes sont des étoiles de la forme `[+q(v1, ..., vl), X1, ..., Xp]` où `+q(v1, ..., vl)` est l'expression correspondant à la requête et `X1, ..., Xp` sont des variables apparaissant dans la requête et que l'on voudrait voir dans le résultat du calcul des réponses à la requête.

### Construire des automates finis

L'encodage d'un automate fini doit nécessairement avoir les deux étoiles suivantes :
- `[-i(W), +a(W, q0)]` encodant l'état initial (où `q0` peut être remplacé par un autre nom)
- `[-a(e, qf), accept]` encodant l'état final (où `qf` peut être remplacé par un autre nom et `e` représente le mot vide "epsilon")

Chaque transition d'un état `q1` vers un état `q2` le long d'une lettre `a` est encodée par une étoile
```
[-a(a . W, q1), +a(W, q2)]
```

Les mots sont encodés par des séquences de caractères séparés par l'opérateur binaire `.` et terminant par `e`. Par exemple `0 . 0 . 1 . e` ou `e` ou encore `1 . b . c . e`.

Il faudra ensuite placer l'automate comme constellation de référence et l'étoile correspondant au mot comme seule étoile de l'espace d'interaction. Exemple d'espace d'interaction pour un automate :

```
{
	[-i(W), +a(W, q0)] +
	[-a(e, q2), accept] +
	[-a(0 . W, q0), +a(W, q0)] +
	[-a(1 . W, q0), +a(W, q0)] +
	[-a(0 . W, q0), +a(W, q1)] +
	[-a(0 . W, q1), +a(W, q2)]
}
|-
{
	[+i(0 . 0 . 0 . e)]
} 
```

### Construire des preuves de la logique linéaire multiplicative

Il est recommandé de suivre la construction proposée dans mon manuscrit de thèse. On traduit chaque axiome par une étoile binaire contenant la traduction des atomes associés.

La traduction d'un atome `a` accessible par une conclusion `c` est donnée par un rayon `+c(t)` où `t` est une séquence de symboles `l` (left) et `r` (right) séparés par l'opérateur binaire `.` et terminant par la variable `X`. L'idée pour la construction de `t` est qu'il encode le chemin de `c` à `a`.

Par exemple si à partir d'une conclusion `c`, on a besoin de remonter en allant deux fois à gauche puis une fois à droite pour atteindre `a`, la traduction de `a` sera `+c(l.l.r.X)`.

Une coupure connectant les conclusions `c1` et `c2` est encodée par l'étoile `[-c1(X), -c2(X)]`.

Étant donné que les structures de preuves peuvent être parcourues en commençant par n'importe quel atome libre, il suffit de placer une étoile avec un atome libre (non polarisé dans ce cas) dans l'espace d'interaction et utiliser le reste de la structure de preuve comme constellation de référence. Plus tard, je vais sûrement ajouter un mode "auto" pour sélectionner automatiquement une étoile de départ car ce n'est pas toujours nécessaire de le faire.

## Références

- Term Rewriting and All That. Baader, Franz.
- Le manuscrit de thèse de Boris Eng qui n'est pas encore sorti.