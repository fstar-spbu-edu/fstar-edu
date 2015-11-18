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

val inc: vNatural -> Tot (x:vNatural{isNotNull x})
let rec inc = function
  | VCons (v, s) VEmpty -> if v = s - 1 then VCons (0, s) (VCons (1, s) VEmpty)
                                        else VCons (v + 1, s)           VEmpty
  | VCons (v, s) t      -> if v = s - 1 then VCons (0, s) (inc t)
                                        else VCons (v + 1, s)  t

val dec: x:vNatural{isNotNull x} -> Tot vNatural
let rec dec = function
  | VCons (0, s) t -> VCons (s - 1, s) (dec t)
  | VCons (x, s) t -> VCons (x - 1, s)      t

val sum: vNatural -> vNatural -> vNatural
let rec sum a b = if isNotNull a then inc (sum (dec a) b) else b
