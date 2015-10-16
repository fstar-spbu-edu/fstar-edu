module VNatural

open VList
open VDigit

type vNatural = x:(vList vDigit){x <> VEmpty /\ x <> VCons 0 _}

val sum: vNatural -> vNatural -> Tot vNatural
let sum a b =
  let rA = rev a
  let rB = rev b
  let rSum = function
    | VEmpty -> fun b -> b
    | VCons h t -> function
      | Vempty      -> VCons h t
      | VCons hh tt -> (VDigit.sum h hh) (rSum t tt)
  rev (rSum rA rB)
