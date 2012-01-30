#use "hol.ml";;
needs "opentheory/io.ml";;
needs "minisatmake.ml";;
let t = article_to_term stdin in thm_to_article stdout (fun () -> sat_prove t);;
