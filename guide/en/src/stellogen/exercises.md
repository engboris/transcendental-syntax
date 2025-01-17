# Exercises

## Paths

Give a value to the variables `answer` so that the following code can be
executed without typing errors.

The idea is that these constellations represent paths to complete in order to
obtain only the constellation `ok` as a result.

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

## Dynamical registers

Start from the following program:

```
init = +r0(0).

print process
  init.
  {replace_me}.
end
```

representing a memory with a register `r0`.

Stellogen can represent memory but in a particular way, by destroying to
construct somewhere else. We cannot content ourselves of updating the register
with a star `-r0(X) +r0(1)` as this star has a circular dependency that would
allow it to be reused an unlimited number of times.

In fact, we can only move the register to modify it, for example with a star
`-r0(0) +r1(1)` that destroys the register `r0` and constructs a register
`r1` containing `1`.

The goal is to define constellations. You can use the code above to do your
tests.

**Exercise 1.** Define two constellations allowing to update the register `r0`to `1` by using an intermediary star to save the value of `r0`.

<details>
  <summary>Solution</summary>
<pre>
<code>-r0(X) +tmp0(X).
-tmp0(X) +r0(1).
</code>
</pre>
</details>

**Exercise 2.** Define a constellation allowing to duplicate and move the register `r0` in two registers `r1` and `r2`.

<details>
  <summary>Solution</summary>
<pre>
<code>-r0(X) +r1(X);
-r0(X) +r2(X).
</code>
</pre>
</details>

**Exercise 3.** Define two constellations allowing to set the value of `r1` to `0` then define two constellations allowing to exchange the values of `r1` and `r2`.

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

**Exercise 4.** How to duplicate `r1` so as to be able to follow and update its copies all at once (as if dealing with a single register) to the value `5`?

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

**Exercise 5.** Using the previous method, duplicate all copies at once.

<details>
  <summary>Solution</summary>
<pre>
<code>-r1(A X) +r1(l A X);
-r1(A X) +r1(r A X).
</code>
</pre>
</details>

## Boolean logic

We want to simulate boolean formulas with constellations. Each question uses
the result of the previous question.

**Exercise 1.** Define a constellation computing negation such that it yields `1` as output when added to the star `@-not(0 X) X` and `0` when added to `@-not(1 X) X`.

<details>
  <summary>Solution</summary>
<pre>
<code>not = +not(0 1); +not(1 0).
</code>
</pre>
</details>

**Exercise 2.** How to display the truth table of negation with a single star, such that we obtain the output `table_not(0 1); table_not(1 0).`?

<details>
  <summary>Solution</summary>
<pre>
<code>print @-not(X Y) table_not(X Y).
</code>
</pre>
</details>

**Exercise 3.** Write in two different ways constellations computing conjunction and disjunction and display their truth table in the same way as for the previous question.

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

**Exercise 4.** Use disjunction and negation to display the truth table of implication given that `X => Y = not(X) \/ Y`.

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

**Exercise 5.** Use implication and conjunction to display the truth table of logical equivalence given that `X <=> Y = (X => Y) /\ (X => Y)`.

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

**Exercise 6.** Define a constellation representing the formula of exclded middle `X \/ ~X`. Display the truth table corresponding to this formula.

<details>
  <summary>Solution</summary>
<pre>
<code>

ex = -not(X R1) -or(R1 X R2) +ex(X R2).
print -ex(X R) table_ex(X R).

</code>
</pre>
</details>

**Exercise 7.** Determine for which values of `X`, `Y` and `Z` the formula `X /\ ~(Y \/ Z)` is true.

<details>
  <summary>Solution</summary>
<pre>
<code>print -or(Y Z R1) -not(R1 R2) -and(X R2 1) x(X) y(Y) z(Z).
</code>
</pre>
</details>
