module EvalDB

type var : Type -> Type -> Type =
   | O : g:Type -> a:Type -> var (g * a) a
   | S : g:Type -> a:Type -> b:Type -> var g a -> var (g * b) a

type tm : Type -> Type -> Type =
   | Var : g:Type -> a:Type -> var g a -> tm g a
   | Lam : g:Type -> a:Type -> b:Type -> body:tm (g * a) b -> tm g (a -> Tot b)
   | App : g:Type -> a:Type -> b:Type -> e1:tm g (a -> Tot b) -> e2:tm g a -> tm g b

val eval_var : g:Type -> a:Type -> var g a -> g -> Tot a
let rec eval_var (g:Type) (a:Type) v env = match v with
   | O 'g0 '_ -> snd #'g0 #a env
   | S 'g0 'a0 'b0 u -> eval_var 'g0 'a0 u (fst #'g0 #'b0 env)

val eval: g:Type -> a:Type -> tm g a -> g -> Tot a
let rec eval (g:Type) (a:Type) t env = match t with
 | Var v -> eval_var g a v env
 | Lam 'gg 'arg 'res body ->
    (fun (x:'arg) -> eval (g * 'arg) 'res body (env,x))
 | App 'gg 'arg 'res e1 e2 ->
    (eval g ('arg -> Tot 'res) e1 env <: 'arg -> Tot 'res (* still need this silly annotation; TODO, fix *))
    (eval g 'arg e2 env)

////////////////////////////////////////////////////////////////////////////////
module EvalDB_CC

type closure : Type -> Type -> Type =
  | Clos : env:Type -> #a:Type -> #b:Type -> x:env -> (y:env{y=x} -> a -> Tot b) -> closure a b

val apply: #a:Type -> #b:Type -> closure a b -> a -> Tot b
let apply (Clos 'env env f) a = f env a

type var : Type -> Type -> Type =
   | O : g:Type -> a:Type -> var (g * a) a
   | S : g:Type -> a:Type -> b:Type -> var g a -> var (g * b) a

type tm : Type -> Type -> Type =
  | Var : #g:Type -> #a:Type -> var g a -> tm g a
  | Lam : g:Type -> a:Type -> b:Type -> body:tm (g * a) b -> tm g (closure a b)
  | App : g:Type -> a:Type -> b:Type -> e1:tm g (closure a b) -> e2:tm g a -> tm g b

val eval_var: g:Type -> a:Type -> var g a -> g -> Tot a
let rec eval_var (g:Type) (a:Type) v env = match v with
	| O 'gg 'aa -> snd #'gg #a env
 	| S 'gg 'aa 'b u -> eval_var 'gg a u (fst #'gg #'b env)

val eval: g:Type -> a:Type -> t:tm g a -> g -> Tot a (decreases %[t;0])
let rec eval (g:Type) (a:Type) t env = match t with
 | Var v -> eval_var g a v env

 | Lam 'gg 'arg 'res body ->
   Clos (tm (g * 'arg) 'res * g)
        #'arg #'res
		     (body, env)
		     (fun (body, env) x -> eval (g * 'arg) 'res body (env, x))
   //can hoist this fun to the top to be mutually recursive with eval since it's now a closed term

 | App 'gg 'aa 'bb e1 e2 -> apply (eval g (closure 'aa a) e1 env)
                                  (eval g 'aa e2 env)

val eval': g:Type -> a:Type -> t:tm g a -> g -> Tot a (decreases %[t;0])
val eval_lam_hoist: g:Type -> arg:Type -> res:Type -> s:(tm (g * arg) res * g) -> arg -> Tot res (decreases %[(fst s); 1])
let rec eval' (g:Type) (a:Type) t env = match t with
  | Var v -> eval_var g a v env

  | Lam 'gg 'arg 'res body ->
    Clos (tm (g * 'arg) 'res * g)
         #'arg
         #'res
		     (body, env)
         (eval_lam_hoist g 'arg 'res)

  | App 'gg 'aa 'bb e1 e2 -> apply (eval' g (closure 'aa a) e1 env)
                                   (eval' g 'aa e2 env)

and eval_lam_hoist (g:Type) (arg:Type) (res:Type) (body, env) x =
    eval' (g * arg) res body (env, x)
