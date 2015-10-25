(*--build-config
    options:--admit_fsi Set --admit_fsi Map --admit_fsi HyperHeap;
    other-files:set.fsi heap.fst map.fsi listTot.fst hyperHeap.fsi
 --*)
(*
   Copyright 2008-2014 Nikhil Swamy and Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)
module FStar.ST
open FStar.HyperHeap
type ref (t:Type) = rref root t
kind STPre = STPre_h t
kind STPost (a:Type) = STPost_h t a
kind STWP (a:Type) = STWP_h t a
new_effect STATE = STATE_h t
effect State (a:Type) (wp:STWP a) =
       STATE a wp wp
effect ST (a:Type) (pre:STPre) (post: (t -> STPost a)) =
       STATE a
             (fun (p:STPost a) (h:t) -> pre h /\ (forall a h1. post h a h1 ==> p a h1)) (* WP *)
             (fun (p:STPost a) (h:t) -> (forall a h1. (pre h /\ post h a h1) ==> p a h1))          (* WLP *)
effect St (a:Type) =
       ST a (fun h -> True) (fun h0 r h1 -> True)
sub_effect
  DIV   ~> STATE = fun (a:Type) (wp:PureWP a) (p:STPost a) (h:t) -> wp (fun a -> p a h)

assume val new_region: r0:rid -> ST rid
      (requires (fun m -> True))
      (ensures (fun (m0:t) (r1:rid) (m1:t) ->
                           extends r1 r0
                        /\ fresh_region r1 m0 m1
                        /\ m1=Map.upd m0 r1 Heap.emp))

assume val ralloc: #a:Type -> i:rid -> init:a -> ST (rref i a)
    (requires (fun m -> True))
    (ensures (fun m0 x m1 ->
                    Let (Map.sel m0 i) (fun region_i ->
                    not (Heap.contains region_i (as_ref x))
                    /\ m1=Map.upd m0 i (Heap.upd region_i (as_ref x) init))))

assume val alloc: #a:Type -> init:a -> ST (ref a)
    (requires (fun m -> True))
    (ensures (fun m0 x m1 ->
                    Let (Map.sel m0 root) (fun region_i ->
                    not (Heap.contains region_i (as_ref x))
                    /\ m1=Map.upd m0 root (Heap.upd region_i (as_ref x) init))))

assume val op_Colon_Equals: #a:Type -> #i:rid -> r:rref i a -> v:a -> ST unit
  (requires (fun m -> True))
  (ensures (fun m0 _u m1 -> m1=Map.upd m0 i (Heap.upd (Map.sel m0 i) (as_ref r) v)))

assume val op_Bang:#a:Type -> #i:rid -> r:rref i a -> ST a
  (requires (fun m -> True))
  (ensures (fun m0 x m1 -> m1=m0 /\ x=Heap.sel (Map.sel m0 i) (as_ref r)))

assume val get: unit -> ST t
  (requires (fun m -> True))
  (ensures (fun m0 x m1 -> m0=x /\ m1=m0))

assume val recall: #a:Type -> #i:rid -> r:rref i a -> STATE unit
   (fun 'p m0 -> Map.contains m0 i /\ Heap.contains (Map.sel m0 i) (as_ref r) ==> 'p () m0)
   (fun 'p m0 -> Map.contains m0 i /\ Heap.contains (Map.sel m0 i) (as_ref r) ==> 'p () m0)
