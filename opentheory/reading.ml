(* ========================================================================= *)
(* OPENTHEORY ARTICLE READING FOR HOL LIGHT                                  *)
(* Ramana Kumar                                                              *)
(* ========================================================================= *)

module Intmap = Map.Make(struct type t = int let compare = compare end);;
module Stringmap = Map.Make(String);;

#load "str.cma";;

let constmap,typemap =
  let int = open_in "opentheory/hol-light.int" in
  let rex =
    Str.regexp "\\(const\\|type\\) \"HOLLight\\.\\(.*\\)\" as \"\\(.*\\)\""
  in
  let rx2 = Str.regexp "\\\\\\(.\\)" in
  let rec read ((c,t) as acc) =
    try let l = input_line int in
    (* parser.ml redefines || *)
      if Pervasives.(||) (String.length l = 0) (String.get l 0 = '#') then
        read acc
      else
        if not (Str.string_match rex l 0) then
          failwith "hol-light.int line bad format"
        else
          let ct = Str.matched_group 1 l in
          let hl = Str.matched_group 2 l in
          let ot = Str.matched_group 3 l in
          let hl = Str.global_replace rx2 "\1" hl in
          match ct with
          | "const" ->
            read (Stringmap.add ot hl c,t)
          | "type" ->
            read (c,Stringmap.add ot hl t)
          | _ -> failwith "shouldn't happen (reading hol-light.int)"
    with End_of_file -> acc in
  let res = read (Stringmap.empty,Stringmap.empty) in
  let () = close_in int in
  res;;

type state =
  { stack:opentheory_object list
  ; thms:thm list
  ; dict:opentheory_object Intmap.t
  }

type reader =
  { axiom:thm list -> term list * term -> thm
  }

let unwrap_term_list =
  List.map (function Term_object t -> t | _ -> failwith "unwrap_term_list")
let unwrap_type_list =
  List.map (function Type_object t -> t | _ -> failwith "unwrap_type_list")

let is_digit = function
  | '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' -> true
  | _ -> false

let read_article_from {axiom=axiom} h =
  let step = function
    | ("absTerm",({stack=Term_object b::Var_object v::os} as st))
      -> {st with stack=Term_object(mk_abs(v,b))::os}
    | ("absThm",({stack=Thm_object th::Var_object v::os} as st))
      -> {st with stack=Thm_object (ABS v th)::os}
    | ("appTerm",({stack=Term_object x::Term_object f::os} as st))
      -> {st with stack=Term_object(mk_comb(f,x))::os}
    | ("appThm",({stack=Thm_object xy::Thm_object fg::os} as st))
      -> {st with stack=Thm_object (MK_COMB(fg,xy))::os}
    | ("assume",({stack=Term_object t::os} as st))
      -> {st with stack=Thm_object (ASSUME t)::os}
    | ("axiom",({stack=Term_object t::List_object ts::os; thms=thms} as st))
      -> {st with stack=Thm_object (axiom thms (unwrap_term_list ts,t))::os}
    | ("betaConv",({stack=Term_object t::os} as st))
      -> {st with stack=Thm_object (BETA_CONV t)::os}
    | ("cons",({stack=List_object t::h::os} as st))
      -> {st with stack=List_object (h::t)::os}
    | ("const",({stack=Name_object n::os} as st))
      -> {st with stack=Const_object (try Stringmap.find n constmap
      with Not_found -> failwith ("No interpretation for constant "^n))::os}
    | ("constTerm",({stack=Type_object ty::Const_object c::os} as st))
      -> {st with stack=Term_object(try mk_mconst(c,ty)
          with Failure _ -> failwith ("Could not create constant "^c))::os}
    | ("deductAntisym",({stack=Thm_object g::Thm_object f::os} as st))
      -> {st with stack=Thm_object (DEDUCT_ANTISYM_RULE f g)::os}
    | ("def",({stack=Num_object k::x::os;dict=dict} as st))
      -> {st with stack=x::os;dict=Intmap.add k x dict}
    | ("eqMp",({stack=Thm_object f::Thm_object fg::os} as st))
      -> {st with stack=Thm_object (EQ_MP fg f)::os}
    | ("nil",({stack=os} as st))
      -> {st with stack=List_object []::os}
    | ("opType",({stack=List_object ts::Type_op_object t::os} as st))
      -> {st with stack=Type_object (mk_type (t, unwrap_type_list ts))::os}
    | ("pop",({stack=_::os} as st))
      -> {st with stack=os}
    | ("ref",({stack=Num_object k::os;dict=dict} as st))
      -> {st with stack=Intmap.find k dict::os}
    | ("refl",({stack=Term_object t::os} as st))
      -> {st with stack=Thm_object (REFL t)::os}
    | ("remove",({stack=Num_object k::os;dict=dict} as st))
      -> {st with stack=Intmap.find k dict::os;dict=Intmap.remove k dict}
    | ("subst",
       ({stack=Thm_object th::List_object[List_object tys;List_object tms]::os}
       as st))
    -> let tys = List.map
         (function List_object [Name_object a; Type_object t] -> (mk_vartype a,t)) tys in
       let tms = List.map
         (function List_object [Var_object v; Term_object t] -> (v,t)) tms in
       let th = INST_TYPE tys th in
       let th = INST tms th in
       {st with stack=Thm_object th::os}
    | ("thm",({stack=Term_object c::List_object hs::Thm_object th::os;thms=thms} as st))
      -> let th = EQ_MP (ALPHA (concl th) c) th in
         let ft th = function
          | Term_object h ->
              let c  = concl th in
              let th = DISCH h th in
              let c' = concl th in
              if aconv c c' then
                ADD_ASSUM h th
              else
                UNDISCH (EQ_MP (LAND_CONV (C ALPHA h) c') th)
          | _ -> failwith "thm: not a list of terms" in
         let th = List.fold_left ft th hs in
      {st with stack=os;thms=th::thms}
    | ("typeOp",({stack=Name_object n::os} as st))
      -> {st with stack=Type_op_object (try Stringmap.find n typemap
      with Not_found -> failwith ("No interpretation for type "^n))::os}
    | ("var",({stack=Type_object t::Name_object n::os} as st))
      -> {st with stack=Var_object(mk_var(n,t))::os}
    | ("varTerm",({stack=Var_object t::os} as st))
      -> {st with stack=Term_object t::os}
    | ("varType",({stack=Name_object n::os} as st))
      -> {st with stack=Type_object(mk_vartype n)::os}
    | (s,({stack=os} as st)) ->
      let c = s.[0] in
      if c = '"' then
        {st with stack=Name_object(String.sub s 1 (String.length s - 2))::os}
      else if c = '#' then
        st
      else if is_digit c then
        {st with stack=Num_object(int_of_string s)::os}
      else failwith ("unhandled article line: "^s)
    in
  let rec loop st = try loop (step (input_line h,st)) with End_of_file -> st in
  (loop {stack=[];dict=Intmap.empty;thms=[]}).thms;;
