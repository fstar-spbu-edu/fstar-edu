module Bug22
open Prims.PURE

type exp =
  | EAbs   : exp -> exp
  | EFalse : exp

val subst : exp -> Tot exp
let subst earg =
  match earg with
  | EAbs ematch ->
      EAbs (if 12 = 43 then ematch else EFalse)
  | _ -> EFalse
