module VNatural

open VDigit
open VList

val isNatural: vList vDigit -> Tot bool
let rec isNatural = function
  | VEmpty    -> false
  | VCons _ t -> true
  
type vNatural = x:(vList vDigit){isNatural x}

val isNotNull: vNatural -> Tot bool
let rec isNotNull = function
  | VCons (0, _) VEmpty -> false
  | VCons (0, _) t      -> isNotNull t
  | _                   -> true

val isDecimal: vNatural -> Tot bool
let rec isDecimal = function
  | VCons (_, 10) VEmpty -> true
  | VCons (_, 10) t      -> isDecimal t
  | _                    -> false

type vDecimal = x:vNatural{isDecimal x}

val inc: vDecimal -> Tot vDecimal
let rec inc = function
  | VCons (9, 10) VEmpty -> VCons (0, 10)    (VCons (1, 10) VEmpty)
  | VCons (9, 10) t      -> VCons (0, 10)    (inc t)
  | VCons (x, 10) t      -> VCons (x + 1, 10) t

val dec: x:vDecimal{isNotNull x} -> Tot vDecimal
let rec dec = function
  | VCons (0, 10) t -> VCons (9, 10)    (dec t)
  | VCons (x, 10) t -> VCons (x - 1, 10) t
