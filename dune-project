(lang dune 3.7)

(name tsyntax)

(generate_opam_files true)

(source
 (github engboris/transcendental-syntax))

(authors "Boris Eng")

(maintainers "Pablo Donato")

(license GPL-3.0-only)

(documentation https://github.com/engboris/transcendental-syntax/blob/main/README.md)

(package
 (name tsyntax)
 (synopsis "Technical interpretation of Girard's transcendental syntax")
 (description "The transcendental syntax provides a low-level language called stellar resolution used to build higher-level abstractions defining types, formulas, proofs and any other logical concepts.")
 (depends base menhir (alcotest :with-test))
 (tags
  ("transcendental syntax" "logic programming" "constraint programming" "resolution logic" "unification" "self-assembly")))

(using menhir 2.1)

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
