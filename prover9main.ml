#use "hol.ml";;
needs "opentheory/io.ml";;
needs "prover9make.ml";;
let t = article_to_term stdin in thm_to_article stdout (fun () -> prover9 t);;
