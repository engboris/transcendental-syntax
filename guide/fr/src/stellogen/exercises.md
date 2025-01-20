# Exercices

## Chemins

Donnez une valeur aux variables `answer` de sorte à pouvoir exécuter
le code suivant sans erreur de typage.

L'idée est que ces constellations représentent des chemins à compléter de sorte
à obtenir seulement la constellation `ok` en résultat.

```
checker = galaxy
  interaction: #test #tested.
  expect: { ok }.
end
empty = {}.

answer = #replace_me.
exercise1 :: empty [checker].
exercise1 = ((-1 ok) {1})[1=>answer].

answer = #replace_me.
exercise2 :: empty [checker].
exercise2 = ((-1; +2) {1})[1=>answer].

answer = #replace_me.
exercise3 :: empty [checker].
exercise3 = ((-1 ok; -2 +3) {1})[1=>answer].

answer = #replace_me.
exercise4 :: empty [checker].
exercise4 = ((-f(+g(X)) ok) {1})[1=>answer].

answer = #replace_me.
exercise5 :: empty [checker].
exercise5 = ((+f(a) +f(b); +g(a); @+g(b) ok) {1})[1=>answer].
```

<details>
  <summary>Solutions</summary>
<pre>
<code>

checker = galaxy
  interaction: #test #tested.
expect: { ok }.
end
empty = {}.

answer = +1.
exercise1 :: empty [checker]
exercise1 = ((-1 ok) {1})[1=>answer].

answer = +1 -2 ok.
exercise2 :: empty [checker]
exercise2 = ((-1; +2) {1})[1=>answer].

answer = +1 +2; -3.
exercise3 :: empty [checker]
exercise3 = ((-1 ok; -2 +3) {1})[1=>answer].

answer = +f(-g(X)).
exercise4 :: empty [checker]
exercise4 = ((-f(+g(X)) ok) {1})[1=>answer].

answer = -f(a); -f(b) -g(a) -g(b).
exercise5 :: empty [checker]
exercise5 = ((+f(a) +f(b); +g(a); @+g(b) ok) {1})[1 => answer].

</code>
</pre>
</details>

## Registres dynamiques

Partons du programme suivant :

```
init = +r0(0).

print process
  init.
  {replace_me}.
end
```

représentant une mémoire avec un registre `r0`.

Stellogen peut représenter la mémoire mais d'une façon particulière, en
détruisant pour construire ailleurs.
On ne peut pas se contenter de mettre à jour le registre avec une étoile
`-r0(X) +r0(1)` car cette étoile a une dépendance circulaire qui lui
permettrait d'être réutilisée un nombre illimité de fois.

En fait, on ne peut que déplacer le registre pour le modifier, par exemple avec
une étoile `-r0(0) +r1(1)` qui détruit le registre `r0` et construit un
registre `r1` contenant `1`.

Le but est de définir des constellations. Vous pouvez utiliser le code ci-dessus
pour faire vos tests.

**Exercice 1.** Définir deux constellations permettant de mettre à jour le
registre `r0` à `1` en utilisant une étoile intermédiaire pour sauvegarder la
valeur de `r0`.

<details>
  <summary>Solution</summary>
<pre>
<code>-r0(X) +tmp0(X).
-tmp0(X) +r0(1).
</code>
</pre>
</details>

**Exercice 2.** Définir une constellation permettant de dupliquer et déplacer
le registre `r0` dans deux registres `r1` et `r2`.

<details>
  <summary>Solution</summary>
<pre>
<code>-r0(X) +r1(X);
-r0(X) +r2(X).
</code>
</pre>
</details>

**Exercice 3.** Définir deux constellation permettant de mettre la valeur de
`r1` à `0` puis définir deux constellations permettant d'échanger les valeurs
de `r1` et `r2`.

<details>
  <summary>Solution</summary>
<pre>
<code>-r1(X) +tmp0(X).
-tmp0(X) +r1(0).
-r1(X) +s1(X); -r2(X) +s2(X).
-s1(X) +r2(X); -s2(X) +r1(X).
</code>
</pre>
</details>

**Exercice 4.** Comment dupliquer `r1` de sorte à pouvoir suivre ses copies et
mettre à jour en une fois (comme si on traitait un seul registre) toutes les
copies à la valeur `5` ?

<details>
  <summary>Solution</summary>
<pre>
<code>-r1(X) +r1(l X);
-r1(X) +r1(r X).
-r1(A X) +tmp0(A X).
-tmp0(A X) +r1(A 5).
</code>
</pre>
</details>

**Exercice 5.** En suivant la méthode précédente, dupliquer chaque copie en une
seule fois.

<details>
  <summary>Solution</summary>
<pre>
<code>-r1(A X) +r1(l A X);
-r1(A X) +r1(r A X).
</code>
</pre>
</details>

## Logique booléenne

On veut simuler des formules booléennes  par des constellations. Chaque
question utilise le résultat de la question précédente.

**Exercice 1.** Définir une constellation calculant la négation de telle sorte
à ce qu'elle produise `1` en sortie lorsqu'elle est ajoutée à l'étoile
`@-not(0 X) X` et `0` lorsqu'ajoutée à `@-not(1 X) X`.

<details>
  <summary>Solution</summary>
<pre>
<code>not = +not(0 1); +not(1 0).
</code>
</pre>
</details>

**Exercice 2.** Comment afficher la table de vérité de la négation avec une
seule étoile, de sorte à ce qu'on obtienne en sortie
`table_not(0 1); table_not(1 0).` ?

<details>
  <summary>Solution</summary>
<pre>
<code>print @-not(X Y) table_not(X Y).
</code>
</pre>
</details>

**Exercice 3.** Ecrire de deux manières différentes des constellations calculant
la conjonction et la disjonction et afficher leur table de vérité de la même
façon que pour la question précédente.

<details>
  <summary>Solution</summary>
<pre>
<code>

and = +and(0 0 0); +and(0 1 0); +and(1 0 0); +and(1 1 1).
or  = +or(0 0 0); +or(0 1 1); +or(1 0 1); +or(1 1 1).

and2 = +and2(0 X 0); +and2(1 X X).
or2  = +or2(0 X X); +or2(1 X 1).

print @-and(X Y R) table_and(X Y R).
print @-or(X Y R) table_or(X Y R).
print @-and2(X Y R) table_and2(X Y R).
print @-or2(X Y R) table_or2(X Y R).

</code>
</pre>
</details>

**Exercice 4.** Utiliser la disjonction et la négation pour afficher la table
de vérité de l'implication sachant que `X => Y = not(X) \/ Y`.

<details>
  <summary>Solution</summary>
<pre>
<code>

impl  = -not(X Y) -or(Y Z R) +impl(X Z R).
impl2 = -not(X Y) -or2(Y Z R) +impl2(X Z R).

print @-impl(X Y R) table_impl(X Y R).
print @-impl2(X Y R) table_impl2(X Y R).

</code>
</pre>
</details>

**Exercice 5.** Utiliser l'implication et la conjonction pour afficher la table
de vérité de l'équivalence logique sachant que `X <=> Y = (X => Y) /\ (X => Y)`.

<details>
  <summary>Solution</summary>
<pre>
<code>

eqq  = -impl(X Y R1) -impl(Y X R2) -and(R1 R2 R) +eqq(X Y R).
eqq2 = -impl2(X Y R1) -impl2(Y X R2) -and2(R1 R2 R) +eqq2(X Y R).

table_eqq  = @-eqq(X Y R) table_eqq(X Y R).
table_eqq2 = @-eqq2(X Y R) table_eqq2(X Y R).

</code>
</pre>
</details>

**Exercice 6.** Définir une constellation représentant la formule du tiers
`X \/ ~X`. Afficher la table de vérité correspondant à cette formule.

<details>
  <summary>Solution</summary>
<pre>
<code>

ex = -not(X R1) -or(R1 X R2) +ex(X R2).
print -ex(X R) table_ex(X R).

</code>
</pre>
</details>

**Exercice 7.** Déterminer pour quelles valeurs de `X`, `Y` et `Z` la formule
`X /\ ~(Y \/ Z)` est vraie.

<details>
  <summary>Solution</summary>
<pre>
<code>print -or(Y Z R1) -not(R1 R2) -and(X R2 1) x(X) y(Y) z(Z).
</code>
</pre>
</details>
