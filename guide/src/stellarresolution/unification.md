# Unification de termes

## Syntaxe

Dans la *théorie de l'unification*, nous écrivons des *termes*. Ce sont soit :
- des *variables* (commençant par une majuscule comme `X`, `Y` ou `Var`);
- des *fonctions* de la forme `f(t1, ..., tn)` où `f` est un *symbole de
fonction* (commençant par une minuscule ou un chiffre) et les expressions
`t1`, ..., `tn` sont d'autres termes.

Tous les identifiants (que cela soit pour les variables ou symboles de
fonction) peuvent contenir les symboles `_`, `?` et terminer par une séquence
de symboles `'`. Par exemple : `x'`, `X''`, `X_1`.

> **Exemples de termes.** `X`, `f(X)`, `h(a, X)`, `parent(X)`, `add(X, Y, Z)`.

On peut aussi omettre la virgule séparant les arguments d'une fonction étant
donné que leur absence de produit pas d'ambiguïté. On écrirait donc
`h(a X)` à la place de `h(a, X)`.

## Principe

Dans la théorie de l'unification, on dit que deux termes sont *unifiables*
lorsqu'il existe une substitution des variables les rendant identiques.
Par exemple, `f(X)` et `f(h(Y))` sont unifiables avec la substitution
`{X:=h(Y)}` remplaçant `X` par `h(Y)`.

Les substitutions qui nous intéressent sont celles qui sont les plus générales.
Nous aurions pu considérer la substitution `{X:=h(c(a)); Y:=c(a)}`, tout aussi
valide mais inutilement précise.

Une autre façon de voir les choses est de voir cela comme brancher des termes
ensemble pour vérifier s'ils sont compatibles se branchent correctement :
- une variable `X` se branche avec tout ce qui ne contient pas `X` comme
sous-terme, sinon nous aurions une dépendance circulaire, comme entre `X` et
`f(X)`;
- une fonction `f(t1, ..., tn)` est compatible avec `f(u1, ..., un)` où `ti`
est compatible avec `ui` pour tout `i`.

- `f(X)` et `f(h(a))` sont compatibles avec `{X:=h(a)}`;
- `f(X)` et `X` sont incompatibles;
- `f(X)` et `g(X)` sont incompatibles;
- `f(h(X))` et `f(h(a))` sont compatibles avec `{X:=a}`.
