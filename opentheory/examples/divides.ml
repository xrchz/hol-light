(* ------------------------------------------------------------------------- *)
(* Natural number divisibility.                                              *)
(* ------------------------------------------------------------------------- *)

logfile "natural-divides-def";;

let divides_def = new_definition
  `!(a:num) b. divides a b <=> ?c. c * a = b`;;

export_thm divides_def;;

logfile "natural-divides-thm";;

let symmetry_reduction = prove
  (`!p : num -> num -> bool.
      (!m n. p m n ==> p n m) /\
      (!m n. m <= n ==> p m n) ==>
      (!m n. p m n)`,
   REPEAT STRIP_TAC THEN
   MP_TAC (SPECL [`m : num`; `n : num`] LE_CASES) THEN
   STRIP_TAC THENL
   [FIRST_X_ASSUM MATCH_MP_TAC THEN
    FIRST_ASSUM ACCEPT_TAC;
    UNDISCH_THEN `!m n : num. p m n ==> p n m` MATCH_MP_TAC THEN
    FIRST_X_ASSUM MATCH_MP_TAC THEN
    FIRST_ASSUM ACCEPT_TAC]);;

let divides_zero = prove
  (`!a. divides a 0`,
   GEN_TAC THEN
   REWRITE_TAC [divides_def] THEN
   EXISTS_TAC `0` THEN
   REWRITE_TAC [MULT]);;

export_thm divides_zero;;

let divides_one = prove
  (`!a. divides a 1 <=> a = 1`,
   REWRITE_TAC [divides_def; MULT_EQ_1; UNWIND_THM2]);;

export_thm divides_one;;

let zero_divides = prove
  (`!a. divides 0 a <=> a = 0`,
   GEN_TAC THEN
   REWRITE_TAC [divides_def; MULT_0] THEN
   MATCH_ACCEPT_TAC EQ_SYM_EQ);;

export_thm zero_divides;;

let one_divides = prove
  (`!a. divides 1 a`,
   GEN_TAC THEN
   REWRITE_TAC [divides_def; MULT_CLAUSES] THEN
   EXISTS_TAC `a : num` THEN
   REFL_TAC);;

export_thm one_divides;;

let divides_refl = prove
  (`!a. divides a a`,
   GEN_TAC THEN
   REWRITE_TAC [divides_def] THEN
   EXISTS_TAC `1` THEN
   REWRITE_TAC [MULT_CLAUSES]);;

export_thm divides_refl;;

let divides_antisym = prove
  (`!a b. divides a b /\ divides b a ==> a = b`,
   REPEAT GEN_TAC THEN
   ASM_CASES_TAC `b = 0` THENL
   [ASM_REWRITE_TAC [zero_divides; divides_zero];
    REWRITE_TAC [divides_def] THEN
    STRIP_TAC THEN
    FIRST_X_ASSUM SUBST_VAR_TAC THEN
    POP_ASSUM MP_TAC THEN
    ASM_REWRITE_TAC [MULTR_EQ; MULT_ASSOC; MULT_EQ_1] THEN
    STRIP_TAC]);;

export_thm divides_antisym;;

let divides_trans = prove
  (`!a b c. divides a b /\ divides b c ==> divides a c`,
   REPEAT GEN_TAC THEN
   REWRITE_TAC [divides_def] THEN
   STRIP_TAC THEN
   REPEAT (FIRST_X_ASSUM SUBST_VAR_TAC) THEN
   EXISTS_TAC `c'' * (c' : num)` THEN
   MATCH_MP_TAC EQ_SYM THEN
   MATCH_ACCEPT_TAC MULT_ASSOC);;

export_thm divides_trans;;

let divides_add = prove
  (`!a b c. divides a b /\ divides a c ==> divides a (b + c)`,
   REPEAT GEN_TAC THEN
   REWRITE_TAC [divides_def] THEN
   STRIP_TAC THEN
   REPEAT (FIRST_X_ASSUM SUBST_VAR_TAC) THEN
   EXISTS_TAC `(c' : num) + c''` THEN
   MATCH_ACCEPT_TAC RIGHT_ADD_DISTRIB);;

export_thm divides_add;;

let divides_sub = prove
  (`!a b c. c <= b /\ divides a b /\ divides a c ==> divides a (b - c)`,
   REPEAT GEN_TAC THEN
   ASM_CASES_TAC `a = 0` THENL
   [ASM_REWRITE_TAC [zero_divides] THEN
    STRIP_TAC THEN
    ASM_REWRITE_TAC [SUB_REFL];
    REWRITE_TAC [divides_def] THEN
    STRIP_TAC THEN
    REPEAT (FIRST_X_ASSUM SUBST_VAR_TAC) THEN
    POP_ASSUM MP_TAC THEN
    ASM_REWRITE_TAC [LE_MULT_RCANCEL] THEN
    STRIP_TAC THEN
    EXISTS_TAC `(c' : num) - c''` THEN
    MATCH_MP_TAC RIGHT_SUB_DISTRIB THEN
    FIRST_ASSUM ACCEPT_TAC]);;

export_thm divides_sub;;

let gcd_induction = prove
  (`!p : num -> num -> bool.
      (!n. p 0 n) /\
      (!m n. n < m /\ p n m ==> p m n) /\
      (!m n. p m n ==> p m (n + m)) ==>
      (!m n. p m n)`,
   REPEAT STRIP_TAC THEN
   WF_INDUCT_TAC `(m : num) + m + n` THEN
   ASM_CASES_TAC `m = 0` THENL
   [FIRST_X_ASSUM SUBST_VAR_TAC THEN
    FIRST_ASSUM MATCH_ACCEPT_TAC;
    ALL_TAC] THEN
   ASM_CASES_TAC `(m : num) <= n` THENL
   [POP_ASSUM MP_TAC THEN
    REWRITE_TAC [LE_EXISTS] THEN
    DISCH_THEN (CHOOSE_THEN SUBST_VAR_TAC) THEN
    ONCE_REWRITE_TAC [ADD_SYM] THEN
    UNDISCH_THEN `!(m : num) n. p m n ==> p m (n + m)` MATCH_MP_TAC THEN
    FIRST_X_ASSUM MATCH_MP_TAC THEN
    REWRITE_TAC [LT_ADD_LCANCEL] THEN
    ASM_REWRITE_TAC [LT_ADDR; LT_NZ];
    POP_ASSUM MP_TAC THEN
    REWRITE_TAC [NOT_LE] THEN
    STRIP_TAC THEN
    UNDISCH_THEN `!(m : num) n. n < m /\ p n m ==> p m n` MATCH_MP_TAC THEN
    ASM_REWRITE_TAC [] THEN
    FIRST_X_ASSUM MATCH_MP_TAC THEN
    CONV_TAC (LAND_CONV (REWR_CONV ADD_SYM)) THEN
    ASM_REWRITE_TAC [ADD_ASSOC; LT_ADD_RCANCEL]]);;

export_thm gcd_induction;;

let gcd_exists = prove
  (`!a b. ?g.
      divides g a /\ divides g b /\
      !c. divides c a /\ divides c b ==> divides c g`,
   MATCH_MP_TAC gcd_induction THEN
   REPEAT STRIP_TAC THENL
   [EXISTS_TAC `g:num` THEN
    ASM_REWRITE_TAC [] THEN
    REPEAT STRIP_TAC THEN
    FIRST_X_ASSUM MATCH_MP_TAC THEN
    ASM_REWRITE_TAC [];
    EXISTS_TAC `b : num` THEN
    REWRITE_TAC [divides_zero; divides_refl];
    EXISTS_TAC `g : num` THEN
    ASM_REWRITE_TAC [] THEN
    REPEAT STRIP_TAC THENL
    [MATCH_MP_TAC divides_add THEN
     ASM_REWRITE_TAC [];
     FIRST_X_ASSUM MATCH_MP_TAC THEN
     ASM_REWRITE_TAC [] THEN
     SUBGOAL_THEN `divides c ((a + b) - b)`
       (fun th -> MP_TAC th THEN REWRITE_TAC [ADD_SUB]) THEN
     MATCH_MP_TAC divides_sub THEN
     ASM_REWRITE_TAC [LE_ADDR]]]);;

export_thm gcd_exists;;

logfile_end ();;