module Bug351b

// copied from FStar.Constructive
type ctrue : Type =
  | I : ctrue

// copied from FStar.Constructive
type cexists : #a:Type -> (a -> Type) -> Type =
  | ExIntro : #a:Type -> #p:(a -> Type) -> x:a -> h:(p x) -> cexists p

// even if the definition of P shouldn't matter below, it actually does
// (everything works if we assume P or if we define it in a simpler way)
type P (a:Type) = (cexists (fun (x:a) -> ctrue))

// all this works fine if we change to h2':(P p -> Tot unit)
val aux : p:Type -> h:P p -> a:(Type->Type) -> h2':(a p -> Tot unit) ->
            Pure unit (requires (a == P)) (ensures (fun _ -> True))
let aux (p:Type) (h:P p) (a:(Type->Type)) h2' = h2' h
// bug351b.fst(16,37-16,38): Subtyping check failed;
// expected type (a p); got type (P p)
