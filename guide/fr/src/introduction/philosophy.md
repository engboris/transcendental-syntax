# Philosophie

## Connectique du sens

Les types, spécifications, algorithmes et formules logiques sont des
**questions** que l'on pose. Elles portent une *intention* qui est subjective.
Les programmes sont des **réponses** à ces questions. Elles sont portées par
une dynamique objective: elles peuvent être implicites et se développer
vers une forme explicite irreductible (c'est l'exécution vers un résultat
du calcul).

La grande question est : comment savoir si l'on est face à une réponse à
une question. Il nous faudrait une connectique de l'interaction entre
question et réponse.

## Iconoclasme et décentralisation

Traditionnellement, la logique et les systèmes de types définissent des
systèmes avec :
- des classes d'entités (individus du premier ordre et relations);
- des règles sémantiques (le compilateur/l'interpréteur est responsable du
sens des expressions et l'utilisateur manipule ces expressions en suivant
ce sens);
- des interactions interdites;
- des interactions autorisées.

Il y a donc une préconception logique. En particulier, les compilateurs
et interpréteurs détiennent le pouvoir sémantique : ils définissent quelles
questions peuvent être posées et comment juger si l'on a une réponse.

Stellogen tente de redonner le pouvoir sémantique à l'utilisateur, devenant
responsable de la création du sens par des briques élémentaires qui composent
à la fois les programmes et les types/formules/specifications.
Les interpréteurs et compilateurs sont ensuite responsables d'un noyau basique
assurant la bonne connexion entre ces briques mais aussi de la
méta-programmation. Nous passons ainsi d'un rôle d'autorité sémantique à un
rôle protocolaire et administratif de l'évaluateur.

## Le sens par l'expérience

Pour savoir si un programme a un certain type (si une réponse satisfait une
question), on procède ainsi :
- on construit un type par un ensemble de tests à passer qui sont eux-mêmes des
programmes;
- on construit un "juge" qui détermine ce que signifie "passer un test";
- on connecte un programme à chaque test du type et on vérifie si le juge
valide toutes les interactions.

Cela nous donnes des garanties non-systémiques et locales similaires aux
commandes "assert" en programmation. Nous pourrions choisir de se mettre
dans des contextes où l'on organiserait des types et contraintes pour former
un système.

## Un ordre dans le chaos

Le modèle de calcul de briques élémentaires avec lequel nous travaillons
pourrait être qualifié de chaotique. Il est possible d'écrire des choses
peu intuitives au résultat peu prédictible. Dans certains cas, la propriété
de confluence n'est même pas valide (deux ordres d'exécutions mènent à deux
résultats différents).

Il y a deux manières d'obtenir un ordre dans le chaos:
- l'émergence naturelle, locale par la création de garanties locales sur des
bouts de programmes;
- l'imposition d'un système fermé définissant des restrictions/contraintes
et dans lequel seul certains types peuvent être utilisés.

Stellogen souhaite laisser les deux possibilités ouvertes. Le premier choix
permettrait une grande flexibilité et le second donnerait l'avantage de
l'efficacité et de l'ergonomie tout en ayant des garanties plus fortes.

## Vérification partielle

Du point de vue de la programmation, et plus particulièrement des méthodes
formelles, Stellogen est motivé par une vérification "partielle" s'opposant aux
vérifications totales où l'on modéliserait entièrement un programme et ses
propriétés pour obtenir des preuves formelles.

Stellogen se concentre sur l'expressivité de contraintes locales qui pourraient
être globalisées dans un système.
