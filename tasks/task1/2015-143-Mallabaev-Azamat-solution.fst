module task1
  type nat = x:int{x>0}
  val fibonacci: nat -> Tot nat
  let rec fibonacci n =
    if n < 1 then fibonacci (n+2) - fibonacci (n+1)
    else if n < 3 then 1
    else fibonacci (n-1) + fibonacci (n-2)
  
  let main n = fibonacci n