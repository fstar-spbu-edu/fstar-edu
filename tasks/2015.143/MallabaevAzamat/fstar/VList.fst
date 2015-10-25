module VList

type vList 'a =
   | VEmpty : vList 'a
   | VCons  : 'a -> vList 'a -> vList 'a

val length: vList 'a -> Tot int
let rec length = function
  | VEmpty    -> 0
  | VCons _ t -> 1 + length t

val isEmpty: vList 'a -> Tot bool
let isEmpty = function
  | VEmpty -> true
  | _      -> false

val isCons: vList 'a -> Tot bool
let isCons = function
  | VCons _ _ -> true
  | _         -> false

val head: l:vList 'a {isCons l} -> Tot 'a
let head = function
  | VCons h _ -> h

val tail: l:vList 'a {isCons l} -> Tot (vList 'a)
let tail = function
  | VCons _ t -> t

val map: ('a -> Tot 'b) -> vList 'a -> Tot (vList 'b)
let rec map f = function
  | VEmpty    -> VEmpty
  | VCons h t -> VCons (f h) (map f t)

val append: vList 'a -> vList 'a -> Tot (vList 'a)
let rec append l1 l2 = match l1 with
  | VEmpty    -> l2
  | VCons h t -> VCons h (append t l2)

val fold: (vList 'a) -> 'b -> ('b -> 'a -> Tot 'b) -> Tot 'b
let rec fold l st f = match l with
  | VEmpty    -> st
  | VCons h t -> fold t (f st h) f

type vOption 'a =
  | VNone : vOption 'a
  | VSome : 'a -> vOption 'a

val fold2: (vList 'b) -> (vList 'c) -> 'a -> ('a -> vOption 'b -> vOption 'c -> Tot 'a) -> Tot 'a
let rec fold2 lb lc a f = match lb, lc with
  | VEmpty,      VEmpty      -> f a VNone VNone
  | VEmpty,      VCons hc tc -> fold2 VEmpty tc     (f a VNone      (VSome hc)) f
  | VCons hb tb, VEmpty      -> fold2 tb     VEmpty (f a (VSome hb) VNone     ) f
  | VCons hb tb, VCons hc tc -> fold2 tb     tc     (f a (VSome hb) (VSome hc)) f

val rev: vList 'a -> Tot (vList 'a)
let rec rev = function
  | VEmpty   -> VEmpty
  | VCons h t -> append (rev t) (VCons h VEmpty)

