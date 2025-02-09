# Introduction

Bienvenue sur le guide du langage Stellogen.

**Notez que ce guide est très expérimental et est suceptible de changer
régulièrement. Le langage présenté est tout aussi instable.**

Je suis intéressé par toutes opinions, recommandations, suggestions ou simples
questions. N'hésitez pas à me contacter à
[boris.eng@proton.me](mailto:boris.eng@proton.me).

Bonne lecture !

## Comment tout a commencé

Stellogen a été créé à partir des recherches de Boris Eng pour comprendre
le programme de syntaxe transcendantale de Jean-Yves Girard.

La syntaxe transcendantale propose un nouveau fondement pour la logique et
le calcul étendant la correspondance de Curry-Howard. Dans ce nouveau
programme, les entités logiques comme les preuves, les formules ou des
concepts comme la vérité sont redéfinis/construits à partir d'un modèle
de calcul élémentaire appelé "résolution stellaire", qui est une sorte
de langage de programmation logique très flexible.

Dans le but de pouvoir expérimenter avec ces idées, Eng a développé un
interpréteur appelé "Large Star Collider (LSC)" permettant d'exécuter des
expressions de la résolution stellaire. Il a initiallement été développé
en Haskell puis finalement redéveloppé en OCaml.

Plus tard, il a été remarqué qu'un langage de metaprogrammation était
nécessaire pour travailler convenablement avec ces objets et notamment
écrire des preuves de la logique linéaire (ce qui était le projet initial).
C'est de là qu'est né le langage Stellogen.

Le langage Stellogen s'est ensuite détaché petit à petit de la syntaxe
transcendantale pour développer ses propres concepts.
