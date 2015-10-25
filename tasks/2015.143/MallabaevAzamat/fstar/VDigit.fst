module VDigit

type nat0 = x:int{x>=0}
type nat1 = x:int{x>=1}

val isDigit: nat0 * nat1 -> Tot bool
let isDigit (v, s) = v < s

type vDigit = t:(nat0 * nat1) {isDigit t}

val sum: vDigit -> vDigit -> Tot vDigit
let sum = function
  | (v1, s1) -> function
  | (v2, s2) -> ((v1 + v2), (s1 + s2))

