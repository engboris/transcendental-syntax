(lang dune 3.7)

(name lsc)

(generate_opam_files true)

(source
 (github engboris/large-star-collider))

(authors "Boris Eng")

(maintainers "Pablo Donato")

(license GPL-3.0-only)

(documentation https://github.com/engboris/large-star-collider/blob/main/README.md)

(package
 (name lsc)
 (synopsis "Stellar resolution implemented with interactive execution")
 (description "The Large Star Collider (LSC) is an implementation of stellar resolution which interprets and executes objects called constellations, which are the programs of stellar resolution.")
 (depends base menhir)
 (tags
  ("transcendental syntax" "logic programming" "constraint programming" "resolution logic" "unification" "asynchronous computation" "self-assembly")))

(using menhir 2.1)

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
