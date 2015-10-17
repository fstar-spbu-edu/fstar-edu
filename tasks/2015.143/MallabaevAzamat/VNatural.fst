module VNatural

open VList
open VDigit

val isNatural: vList vDigit -> Tot bool
let isNatural = function
  | VEmpty         -> false
  | VCons (0, _) _ -> false
  | _              -> true
  
type vNatural = x:(vList vDigit){isNatural x}

val isDecimal: vList vDigit -> Tot bool
let rec isDecimal = function
  | VEmpty          -> true
  | VCons (_, 10) t -> isDecimal t
  | VCons _ _       -> false

type vDecimal = x:vNatural{isDecimal x}

val sum: vDecimal -> vDecimal -> vDecimal
let sum a b = rev (fold2 (rev a) (rev b) (VCons (0, 10) VEmpty) (fun a b c -> match a with
  | VCons (vc, 10) t -> match b with
    | VNone -> match c with
      | VNone          -> VCons (0,                   10) (VCons (           vc,       10) t)
      | VSome (vb, 10) -> VCons ((     vb + vc) / 10, 10) (VCons ((     vb + vc) % 10, 10) t)
    | VSome (va, 10) -> match c with
      | VNone          -> VCons ((va +      vc) / 10, 10) (VCons ((va +      vc) % 10, 10) t)
      | VSome (vb, 10) -> VCons ((va + vb + vc) / 10, 10) (VCons ((va + vb + vc) % 10, 10) t)))

