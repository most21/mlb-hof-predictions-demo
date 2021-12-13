(lang dune 2.9)

(generate_opam_files true)
  (authors "Matthew Ost")
  (maintainers "most1@jhu.edu")
  (package
   (name mlb-hof)
   (synopsis "An OCaml command line tool to explore the Hall of Fame candidacy of Major League Baseball players.")
   (description "The tool performs analysis using 2 methods: a peak-WAR classifier based on Jay Jaffe's JAWS system and a KNN classifier.")
   (depends
    (ounit2 (> 2.0))
    (core (> 0.14.1))
    (owl (> 1.0.1))
    (sqlite3 (> 5.1.0))
 ))