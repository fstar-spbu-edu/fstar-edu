module Bug213

type intPair =
  | IP : f:int -> intPair

type cexists : a:Type -> (a -> Type) -> Type =
  | ExIntro : #a:Type -> #p:(a -> Type) -> x:a -> p x -> cexists a p

val foo : cexists intPair (fun (p:intPair) -> unit) -> Tot unit
let foo h =
  let ExIntro (IP p) hp = h in
  ()
