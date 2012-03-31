(* ========================================================================= *)
(* OPENTHEORY EXAMPLE THEORIES                                               *)
(* Joe Hurd                                                                  *)
(* ========================================================================= *)

(* ------------------------------------------------------------------------- *)
(* The interpretation for the example theories.                              *)
(* ------------------------------------------------------------------------- *)

extend_the_interpretation "opentheory/interpretations/examples.int";;

(* ------------------------------------------------------------------------- *)
(* Start proof logging.                                                      *)
(* ------------------------------------------------------------------------- *)

start_logging ();;

(* ------------------------------------------------------------------------- *)
(* Streams.                                                                  *)
(* ------------------------------------------------------------------------- *)

loads "opentheory/examples/stream.ml";;

(* ------------------------------------------------------------------------- *)
(* Probability.                                                              *)
(* ------------------------------------------------------------------------- *)

loads "opentheory/examples/probability.ml";;

(* ------------------------------------------------------------------------- *)
(* Natural number division.                                                  *)
(* ------------------------------------------------------------------------- *)

loads "opentheory/examples/divides.ml";;

loads "opentheory/examples/gcd.ml";;

loads "opentheory/examples/prime.ml";;

(* ------------------------------------------------------------------------- *)
(* Fibonacci encoding of natural numbers.                                    *)
(* ------------------------------------------------------------------------- *)

loads "opentheory/examples/fibonacci.ml";;

(* ------------------------------------------------------------------------- *)
(* Modular arithmetic.                                                       *)
(* ------------------------------------------------------------------------- *)

loads "opentheory/examples/modular.ml";;

(* ------------------------------------------------------------------------- *)
(* Finite fields GF(p).                                                      *)
(* ------------------------------------------------------------------------- *)

loads "opentheory/examples/gfp.ml";;

(* ------------------------------------------------------------------------- *)
(* Bit-vectors.                                                              *)
(* ------------------------------------------------------------------------- *)

loads "opentheory/examples/word.ml";;

loads "opentheory/examples/byte.ml";;

loads "opentheory/examples/word10.ml";;

loads "opentheory/examples/word12.ml";;

loads "opentheory/examples/word16.ml";;

(* ------------------------------------------------------------------------- *)
(* Simple stream parsers.                                                    *)
(* ------------------------------------------------------------------------- *)

loads "opentheory/examples/parser.ml";;

loads "opentheory/examples/char.ml";;

(* ------------------------------------------------------------------------- *)
(* Memory safety for the H interface.                                        *)
(* ------------------------------------------------------------------------- *)

(***
loads "opentheory/examples/h.ml";;
***)

(* ------------------------------------------------------------------------- *)
(* Map reduce example using Minisat.                                         *)
(* ------------------------------------------------------------------------- *)

(*
loads "opentheory/examples/map-reduce.ml";;
*)

(* ------------------------------------------------------------------------- *)
(* Stop proof logging.                                                       *)
(* ------------------------------------------------------------------------- *)

stop_logging ();;
