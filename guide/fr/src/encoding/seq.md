# Sequences

## Algebraic case

### Fixed sequences

```
+seq(a b c d).
```

We can retrieve the head element with:

```
head = +head(-seq(X1 X2 X3 X4) X1).
query = -head(+seq(1 2 3 4) R) R.
print (query head).
```

### Constants stack

```
+list(a(b(c(e)))).
```

We can push or pop a head element with:

```
l = +list(a(b(c(e)))).
print process
  l.
  'push
    -list(X) +tmp(new(X)).
    -tmp(X) +list(X).
  'pop
    -list(new(X)) +list(X).
end
```

> **Remark.**  We cannot reason on an generic function symbol.
Therefore, it is only possible to push and pop specific symbols. To fix this,
we must use function symbols as constructors instead (and not as a value).

### General lists

We can imagine several equivalent representations by using function symbols to
concatenate elements together.

```
+list(a:b:c:d:e).
+list(cons(a, cons(b, cons(c, cons(d, e))))).
+cons(a, +cons(b, +cons(c, +cons(d, e)))).
```

It is possible to add and remove elements like this:

```
l = +list(a:b:c:d:e).
print process
  l.
  'push
    -list(X) +tmp(new:X).
    -tmp(X) +list(X).
  'pop
    -list(C:X) +list(X).
end
```

By following the principles of logic programming, it is possible to check if
a list is empty:

```
empty? = +empty?(e).

print empty? @-empty?(e) ok.
print empty? @-empty?(1:e) ok.
```

Concatenate two lists:

```
append =
  +append(e L L);
  -append(T L R) +append(H:T L H:R).

print append @-append(a:b:e c:d:e R) R.
```

Reverse a list:

```
rev =
  +revacc(e ACC ACC);
  -revacc(T H:ACC R) +revacc(H:T ACC R);
  -revacc(L e R) +rev(L R).

print rev @-rev(a:b:c:d:e R) R.
```

Apply a function over all elements of a list:

```
map =
  +map(X e e);
  -funcall(F H FH) -map(F T R) +map(F H:T FH:R).

print
  map
  +funcall(f X f(X));
  @-map(f a:b:c:d:e R) R.
```

## Interactive case

### Sets

```
c = +e1(a); +e2(b); e3(c).
```

### Chains

```
c =
  @-e(1 X) +e(2 a);
  -e(2 X) +e(3 b);
  -e(3 X) +e(4 c);
  -e(4 X) +e(5 d).
```

### Linked lists

```
c =
  @+e(1 e);
  -e(1 X) +e(2 a:X);
  -e(2 X) +e(3 b:X);
  -e(3 X) +e(4 c:X);
  -e(4 X) +e(5 d:X).
```
