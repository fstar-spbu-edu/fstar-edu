module BugWildcardTelescopes
assume type a
assume type b : a -> Type
assume type c
type entry =
  | Entry : a:a -> b:b a -> entry
                          
val foo2: l:entry -> Tot unit
let foo2 l = match l with
  | Entry _ b -> ()


type simple =
  | T1 : int -> int -> simple
  | T2 : int -> int -> simple

let bar = function
  | T1 x _
  | T2 _ x -> x



////////////////////////////////////////////////////////////////////////////////
type d =
  | E : a:int{a=0} -> d
  | F : a:int{a=1} -> d

let f = function
  | E x
  | F x -> (* The type of x is x:int{x=0 || x =1} *)
   assert (x=0 || x=1)
////////////////////////////////////////////////////////////////////////////////

type t : int -> Type
type e =
  | G : a:int -> b:t a -> e
  | H : a:int -> b:t a -> e

assume val use_b: #x:int -> t x -> Tot unit                          
val foo3: e -> Tot unit
let foo3 = function
  | G _ b -> use_b b
  | H _ b -> use_b b

(* Note, the following is rightfully rejected:

val foo4: e -> Tot unit
let foo4 = function
  | G _ b 
  | H _ b -> use_b b


   because  what is the type of b?
             wc0:int{wc0 = 0}, b:t wc0, wc1:int{wc1=1}
             For (F wc1 b) to be typeable, we require b:t wc1

 *)
