module VDigit

type nat0 = x:int{x>=0}
type nat2 = x:int{x>=2}

val isDigit: nat0 * nat2 -> Tot bool
let isDigit (v, s) = v < s

type vDigit = t:(nat0 * nat2) {isDigit t}
