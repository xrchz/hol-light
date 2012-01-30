#use "hol.ml";;
needs "Examples/prover9.ml";;
needs "opentheory/io.ml";;
let t = article_to_term stdin in thm_to_article stdout (fun () -> rPROVER9 t);;
