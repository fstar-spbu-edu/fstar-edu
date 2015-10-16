module VDigit

open VList

val isDigit: int * int -> Tot bool
let isDigit (v, s) = v < s && 0 < v

type vDigit = t:(int * int) {isDigit t}

val sum: vDigit -> vDigit -> Tot vDigit
let sum = function
  | (v1, s1) -> function
  | (v2, s2) -> ((v1 + v2), (s1 + s2))

val reduce: (int -> int) -> vDigit -> x:Tot (vList vDigit) {x <> VEmpty}
let reduce rule = 
  VCons (v, rule level) VEmpty

