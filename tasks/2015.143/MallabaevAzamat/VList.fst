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

val fold: 'b -> ('a -> 'b -> 'b) -> vList 'a -> Tot 'b
let rec fold st f = function
  | VEmpty    -> st
  | VCons h t -> fold (f h) f t

val map: ('a -> Tot 'b) -> vList 'a -> Tot (vList 'b)
let rec map f = function
  | VEmpty    -> VEmpty
  | VCons h t -> VCons (f h) (map f t)

val rev: vList 'a -> Tot (vList 'a)
let rev f = fold VEmpty VCons f

val append: vList 'a -> vList 'a -> Tot (vList 'a)
let rec append = function
  | VEmpty    -> fun l -> l
  | VCons h t -> fun l -> VCons h (append t l)
