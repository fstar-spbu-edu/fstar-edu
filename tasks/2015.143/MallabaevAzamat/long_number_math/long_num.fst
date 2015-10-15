type LongNum = x: Sign * y: List<Digit> { (y = Nil /\ x = Plus) \/ (y = Cons(a, _) /\ a <> 0) }
