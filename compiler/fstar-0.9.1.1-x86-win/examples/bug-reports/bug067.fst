module Bug67
type Good (i:int) (j:int) = True
val test : l1:int -> Tot (l2:int -> Tot (u:unit{Good l1 l2}))
let test l1 l2 = ()
let x = assert True //only need this to trigger the encoding of what comes previously
