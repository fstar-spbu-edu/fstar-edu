(*--build-config
    options:--admit_fsi FStar.Set --admit_fsi FStar.Map --logQueries;
    other-files:../../lib/set.fsi ../../lib/heap.fst ../../lib/st.fst ../../lib/all.fst ../../lib/map.fsi ../../lib/twoLevelHeap.fst
 --*)

module TestTwoLevelHeap
open FStar.TwoLevelHeap

val test0: #r:rid -> i:int -> v:rref r int -> ST int
  (requires (fun m0 -> Map.contains m0 r))
  (ensures (fun m0 k m1 -> k=i+sel m0 v
                        /\ modifies Set.empty m0 m1))
let test0 _r i v =
  let r = new_region () in
  let x = ralloc r i in
  let j = !x in
  x := j + !v;
  !x
