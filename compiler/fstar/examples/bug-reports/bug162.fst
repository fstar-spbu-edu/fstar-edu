module Bug162

type heap = int -> Tot int
type Good (h:heap) = forall x. h x > x
val eval: h:heap{Good h} -> nat -> Tot nat
let rec eval h n = match n with
  | 0 -> 0
  | _ -> eval (fun x -> h x + 1) (n - 1)
