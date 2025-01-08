# Transcendental Syntax

Logic usually lives in more or less intercompatible *logical systems*. We can
speak of logical pluralism.

Logics usually function with a computational basis named *syntax* that
follows rules dictated by a higher level syntax named *semantic*. In
particular, are imposed: usable objects, their form, their possible
interactions, and the formulas or specifications that can be expressed.

This action at a distance between two hermetic spaces, while being the fruit
of our perception of a certain structuration of reality, is an obstacle to
the manipulation and understanding of logical mechanisms. Logical reality as
such is not directly accessible (why would it be?).

Our understanding of logic can only rest on apparently arbitrary, while
effective, considerations. One needs to be able to justify their relevance
and to recontextualize, if not *naturalize* them (and thus maybe obtain a
science of logic?). Transcendental syntax, conceived by Jean-Yves Girard,
proposes:

 - a reorganization of the concepts of computation and logic to highlight
 their distinctions and interactions;
 - a reverse engineering of logic from syntactic computation allowing us to
 reframe our knowledge in a new logical environment;
 - a computational justification of logical principles.

## Example in automata theory

A finite automaton is a machine that can read a word (letter by letter and
without memory) then accept it or not. An automaton can be characterized
by its set of accepted words, making up its *recognized language*.

If faced with some given automaton, how to determine its recognized language?
There are multiple possibilities:

 - analyze the automaton by evaluating and judging it (semantic option we
 want to avoid);
 - look at how it reacts against every word (rational but unrealistic option).
 What Girard calls the *usage sense*;
 - immerse the representation of automata and words in another larger
 interaction space in which we could test (in a more effective way) the
 automaton's reaction against a finite number of "exotic" objects allowing us
 to determine its recognized language. What Girard calls the *usine
 sense*.
