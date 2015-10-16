(*--build-config
    options:--admit_fsi FStar.Set; 
    other-files:set.fsi heap.fst st.fst all.fst st2.fst
  --*)

module Bug

open FStar.Comp
open FStar.Relational

type ni_exp (l:unit) = unit -> St2 (double int)

val expr : unit -> Tot (ni_exp ()) 
(* The inlined version works *)
(* val expr : unit -> Tot (unit -> St2 (double int)) *)
let expr () = fun () -> compose2 (fun _ -> 0) (fun _ -> 0) (twice ()) 

(* This also works *)
val expr' : unit -> Tot (ni_exp ()) 
let expr' () = (fun () -> compose2 (fun _ -> 0) (fun _ -> 0) (twice ()))
