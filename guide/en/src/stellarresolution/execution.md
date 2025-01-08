# Execution of Constellations

## Fusion of Stars

Stars interact with each other using an operation called fusion (which can be
likened to an interaction protocol) based on the principle of *Robinson's
resolution rule*.

The fusion of two stars:

```
r r1 ... rk
```

and

```
r' r1' ... rk'
```

along their rays `r` and `r'` is defined by a new star:

```
theta(r1) ... theta(rk) theta(r1') ... theta(rk')
```

where `theta` is the most general substitution induced by `r` and `r'`.

Note that:

- `r` and `r'` are annihilated during the fusion;
- the two stars merge;
- the substitution obtained from resolving the conflict between `r` and `r'`
propagates to the adjacent rays.

> **Example:** The fusion of `X +f(X)` and `-f($a)` makes `+f(X)` and
`-f($a)` interact, propagating the substitution `{X:=$a}` to the remaining
ray `X`. The result is `X{X:=a}`, i.e., `a`.

> This fusion operation corresponds to the cut rule in first-order logic (also linked to the resolution rule). However, the context here is "alogical" (our objects carry no logical meaning).

## Execution

Execution is somewhat akin to solving a puzzle. You start with a constellation made up of several stars. Choose some *initial stars*, then create copies of other stars to interact with them through fusion. The process continues until no further interactions are possible (saturation). The final constellation is the result of the execution.

Formally, the constellation is split into two parts for execution:
- the set of *initial stars* (serving as a workspace or interaction space);
the rest, referred to as *reference stars*.

This separation can be represented as follows, with reference stars on the left and initial stars on the right, separated by the symbol `|-`:

```
s1 ... sn |- s1' ... sm'
```

Execution proceeds as follows:
1. Select a ray `r'` from an initial star `s'`;
2. Find all possible connections with rays `r` from reference stars `s`;
3. Duplicate `s'` on the right for each such ray `r` found;
4. Replace each copy of `s'` with the fusion of `s` and `s'`;
5. Repeat until no further interactions are possible in the space of initial
stars.

## Example

Consider the execution of the following constellation, where the only initial
star is prefixed by `@`:

```
+add($0 Y Y);
-add(X Y Z) +add($s(X) Y $s(Z));
@-add($s($s($0)) $s($s($0)) R) R.
```

For clarity, the selected rays will be highlighted with `>>` and `<<`.
The steps are as follows:

```
+add($0 Y Y);
-add(X Y Z) +add($s(X) Y $s(Z));
@-add($s($s($0)) $s($s($0)) R) R.
```

The initial separation is:

```
+add($0 Y Y);
-add(X Y Z) +add($s(X) Y $s(Z))
|-
-add($s($s($0)) $s($s($0)) R) R
```

Select the first ray

```
+add($0 Y Y);
-add(X Y Z) +add($s(X) Y $s(Z))
|-
>>-add($s($s($0))<< $s($s($0)) R) R
```

`+add($0 Y Y)` cannot interact with `-add($s($s($0)) $s($s($0)) R)`
because the first argument `$0` is incompatible with `$s($s($0))`. However, it can interact with `+add($s(X) Y $s(Z))`. Fusing:

```
-add(X Y Z) +add($s(X) Y $s(Z))
```

with

```
-add($s($s($0)) $s($s($0)) R) R
```

produces the substitution `{X:=$s($0), Y:=$s($s($0)), R:=$s(Z)}` and the result:

```
-add($s($0) $s($s($0)) Z) $s(Z)
```

This leads to:

```
+add($0 Y Y);
-add(X Y Z) >>+add($s(X) Y $s(Z))<<
|-
-add($s($0) $s($s($0)) Z) $s(Z)
```

Select the first ray again

```
+add($0 Y Y);
-add(X Y Z) +add($s(X) Y $s(Z))
|-
>>-add($s($0) $s($s($0)) Z)<< $s(Z)
```

It can interact with `+add($s(X) Y $s(Z))`,
giving the substitution `{X:=$0, Y:=$s($s($0)), Z:=$s(Z')}`:

```
+add($0 Y Y);
-add(X Y Z) +add($s(X) Y $s(Z))
|-
-add($0 $s($s($0)) Z') $s($s(Z'))
```

Selecting the first ray once more

```
+add($0 Y Y);
-add(X Y Z) +add($s(X) Y $s(Z))
|-
>>-add($0 $s($s($0)) Z')<< $s($s(Z'))
```

This ray interacts only with the first reference star `+add($0 Y Y)`, resulting
in:

```
+add($0 Y Y);
-add(X Y Z) +add($s(X) Y $s(Z))
|-
$s($s($s($s($0))))
```

The result of the execution is:

```
$s($s($s($s($0))))
```
