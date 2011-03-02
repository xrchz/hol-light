(* word16 *)

(* word16-def *)

new_constant ("word16_size", `:num`);;

let word16_size_def = new_axiom
  `word16_size = 2 EXP word16_width`;;

let word16_size_nonzero = new_axiom
  `~(word16_size = 0)`;;

(* word16 *)

(* word16-mod *)

let mod_lt_word16_size = new_axiom
  `!n. n < word16_size ==> n MOD word16_size = n`;;

let lt_mod_word16_size = new_axiom
  `!n. n MOD word16_size < word16_size`;;

let mod_mod_refl_word16_size = new_axiom
  `!n. n MOD word16_size MOD word16_size = n MOD word16_size`;;

let mod_add_mod_word16_size = new_axiom
  `!m n. (m MOD word16_size + n MOD word16_size) MOD word16_size = (m + n) MOD word16_size`;;

let mod_mult_mod2_word16_size = new_axiom
  `!m n. (m MOD word16_size * n MOD word16_size) MOD word16_size = (m * n) MOD word16_size`;;

(* word16-def *)

new_type ("word16",0);;

new_constant ("num_to_word16", `:num -> word16`);;

new_constant ("word16_to_num", `:word16 -> num`);;

let word16_to_num_to_word16 = new_axiom
  `!x. num_to_word16 (word16_to_num x) = x`;;

let num_to_word16_inj = new_axiom
   `!x y.
      x < word16_size /\ y < word16_size /\ num_to_word16 x = num_to_word16 y ==>
      x = y`;;

let num_to_word16_to_num = new_axiom
  `!x. word16_to_num (num_to_word16 x) = x MOD word16_size`;;

new_constant ("word16_add", `:word16 -> word16 -> word16`);;

let num_to_word16_add = new_axiom
  `!x1 y1.
     num_to_word16 (x1 + y1) =
     word16_add (num_to_word16 x1) (num_to_word16 y1)`;;

new_constant ("word16_mult", `:word16 -> word16 -> word16`);;

let num_to_word16_mult = new_axiom
  `!x1 y1.
     num_to_word16 (x1 * y1) =
     word16_mult (num_to_word16 x1) (num_to_word16 y1)`;;

new_constant ("word16_neg", `:word16 -> word16`);;

let word16_neg_def = new_axiom
  `!x. word16_neg x = num_to_word16 (word16_size - word16_to_num x)`;;

new_constant ("word16_sub", `:word16 -> word16 -> word16`);;

let word16_sub_def = new_axiom
  `!x y. word16_sub x y = word16_add x (word16_neg y)`;;

new_constant ("word16_le", `:word16 -> word16 -> bool`);;

let word16_le_def = new_axiom
  `!x y. word16_le x y = word16_to_num x <= word16_to_num y`;;

new_constant ("word16_lt", `:word16 -> word16 -> bool`);;

let word16_lt_def = new_axiom
  `!x y. word16_lt x y = ~(word16_le y x)`;;

(* word16-thm *)

let word16_to_num_inj = new_axiom
  `!x y. word16_to_num x = word16_to_num y ==> x = y`;;

let num_to_word16_eq = new_axiom
   `!x y.
      num_to_word16 x = num_to_word16 y <=> x MOD word16_size = y MOD word16_size`;;

let word16_to_num_bound = new_axiom
  `!x. word16_to_num x < word16_size`;;

let word16_to_num_div_bound = new_axiom
  `!x. word16_to_num x DIV word16_size = 0`;;

let word16_add_to_num = new_axiom
   `!x y.
      word16_to_num (word16_add x y) =
      (word16_to_num x + word16_to_num y) MOD word16_size`;;

(* word16-bits-def *)

new_constant ("word16_shl", `:word16 -> num -> word16`);;

let word16_shl_def = new_axiom
  `!w n. word16_shl w n = num_to_word16 ((2 EXP n) * word16_to_num w)`;;

new_constant ("word16_shr", `:word16 -> num -> word16`);;

let word16_shr_def = new_axiom
  `!w n. word16_shr w n = num_to_word16 (word16_to_num w DIV (2 EXP n))`;;

new_constant ("word16_bit", `:word16 -> num -> bool`);;

let word16_bit_def = new_axiom
  `!w n. word16_bit w n = ODD (word16_to_num (word16_shr w n))`;;

new_constant ("word16_to_list", `:word16 -> bool list`);;

let word16_to_list_def = new_axiom
  `!w. word16_to_list w = MAP (word16_bit w) (interval 0 word16_width)`;;

new_constant ("list_to_word16", `:bool list -> word16`);;

let list_to_word16_def = new_axiom
  `(list_to_word16 [] = num_to_word16 0) /\
   (!h t.
      list_to_word16 (CONS h t) =
      if h then word16_add (word16_shl (list_to_word16 t) 1) (num_to_word16 1)
      else word16_shl (list_to_word16 t) 1)`;;

new_constant ("is_word16_list", `:bool list -> bool`);;

let is_word16_list_def = new_axiom
  `!l. is_word16_list (l : bool list) <=> LENGTH l = word16_width`;;

new_constant ("word16_and", `:word16 -> word16 -> word16`);;

let word16_and_def = new_axiom
  `!w1 w2.
     word16_and w1 w2 =
     list_to_word16 (zipwith ( /\ ) (word16_to_list w1) (word16_to_list w2))`;;

new_constant ("word16_or", `:word16 -> word16 -> word16`);;

let word16_or_def = new_axiom
  `!w1 w2.
     word16_or w1 w2 =
     list_to_word16 (zipwith ( \/ ) (word16_to_list w1) (word16_to_list w2))`;;

new_constant ("word16_not", `:word16 -> word16`);;

let word16_not_def = new_axiom
  `!w. word16_not w = list_to_word16 (MAP (~) (word16_to_list w))`;;

(* word16-bits-thm *)

let length_word16_to_list = new_axiom
  `!w. LENGTH (word16_to_list w) = word16_width`;;

let is_word16_to_list = new_axiom
  `!w. is_word16_list (word16_to_list w)`;;

let word16_bit_div = new_axiom
  `!w n. word16_bit w n = ODD (word16_to_num w DIV (2 EXP n))`;;

let nil_to_word16_to_num = new_axiom
  `word16_to_num (list_to_word16 []) = 0`;;

let cons_to_word16_to_num = new_axiom
   `!h t.
      word16_to_num (list_to_word16 (CONS h t)) =
      (2 * word16_to_num (list_to_word16 t) + (if h then 1 else 0)) MOD word16_size`;;

let list_to_word16_to_num_bound = new_axiom
  `!l. word16_to_num (list_to_word16 l) < 2 EXP (LENGTH l)`;;

let list_to_word16_to_num_bound_suc = new_axiom
  `!l. 2 * word16_to_num (list_to_word16 l) + 1 < 2 EXP (SUC (LENGTH l))`;;

let cons_to_word16_to_num_bound = new_axiom
   `!h t.
      2 * word16_to_num (list_to_word16 t) + (if h then 1 else 0) <
      2 EXP SUC (LENGTH t)`;;

let word16_to_list_to_word16 = new_axiom
  `!w. list_to_word16 (word16_to_list w) = w`;;

let word16_to_list_inj = new_axiom
  `!w1 w2. word16_to_list w1 = word16_to_list w2 ==> w1 = w2`;;

let list_to_word16_bit = new_axiom
   `!l n.
      word16_bit (list_to_word16 l) n =
      (n < word16_width /\ n < LENGTH l /\ EL n l)`;;

let short_list_to_word16_to_list = new_axiom
   `!l.
      LENGTH l <= word16_width ==>
      word16_to_list (list_to_word16 l) =
      APPEND l (REPLICATE (word16_width - LENGTH l) F)`;;

let long_list_to_word16_to_list = new_axiom
   `!l.
      word16_width <= LENGTH l ==>
      word16_to_list (list_to_word16 l) = take word16_width l`;;

let list_to_word16_to_list_eq = new_axiom
   `!l.
      word16_to_list (list_to_word16 l) =
      if LENGTH l <= word16_width then
        APPEND l (REPLICATE (word16_width - LENGTH l) F)
      else
        take word16_width l`;;

let list_to_word16_to_list = new_axiom
  `!l. LENGTH l = word16_width <=> word16_to_list (list_to_word16 l) = l`;;

let word16_shl_list = new_axiom
   `!l n.
      word16_shl (list_to_word16 l) n =
      list_to_word16 (APPEND (REPLICATE n F) l)`;;

let short_word16_shr_list = new_axiom
   `!l n.
      LENGTH l <= word16_width ==>
      word16_shr (list_to_word16 l) n =
      (if LENGTH l <= n then list_to_word16 []
       else list_to_word16 (drop n l))`;;

let long_word16_shr_list = new_axiom
   `!l n.
      word16_width <= LENGTH l ==>
      word16_shr (list_to_word16 l) n =
      if word16_width <= n then list_to_word16 []
      else list_to_word16 (drop n (take word16_width l))`;;

let word16_shr_list = new_axiom
   `!l n.
      word16_shr (list_to_word16 l) n =
      (if LENGTH l <= word16_width then
         if LENGTH l <= n then list_to_word16 []
         else list_to_word16 (drop n l)
       else
         if word16_width <= n then list_to_word16 []
         else list_to_word16 (drop n (take word16_width l)))`;;

let word16_eq_bits = new_axiom
  `!w1 w2. (!i. i < word16_width ==> word16_bit w1 i = word16_bit w2 i) ==> w1 = w2`;;