module VDigit

type nat0 = x:int{x>=0}
type nat1 = x:int{x>=1}

val isDigit: nat0 * nat1 -> Tot bool
let isDigit (v, s) = v < s

type vDigit = t:(nat0 * nat1) {isDigit t}
