module Bug283
type block 
assume val xor : block -> block -> Tot block

assume XOR_Laws:forall a b.{:pattern (xor a b)} xor a b = xor b a /\ xor (xor a b) a = b
val test2 : unit -> Lemma (forall a b. xor (xor a b) b = a) 
let test2 () = ()
