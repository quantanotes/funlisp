|# Continuation Passing Style Transform

Unapologetically ripped off from Matt Might.

exp = aexp
    | (begin exp*)
    | (prim exp*)
    | (exp exp*)

aexp = (fun (symbol*) exp)
     | atom

cexp = (aexp aexp*)
     | ((cps prim) aexp*)
|#

(begin
    ; exp -> aexp
    (defun m (x)
        (cond
            ((atom? x) x)
            ((fun?  x) (m-fun x))))

    (defun m-fun (x)
        (let
            ((a  (fun-args x))
             (b  (fun-body x))
             ($k (gensym 'k)))
             `(fun (,@a ,$k) ,(tc b $k))))

    ; exp | aexp -> cexp 
    (defun tc (x c)
        (cond
            ((aexp?  x) `(,c ,(m x)))
            ((apply? x) (tc-apply x c))))

    (defun tc-apply (x c)
        (let
            ((f  (apply-fun x))
             (a  (apply-args x)))
             (tk f (fun ($f)
                (t*k a (fun ($a)
                    `(,$f ,@$a ,c)))))))
    
    ; exp | (aexp -> cexp) -> cexp
    (defun tk (x k)
        (cond
            ((aexp?  x) (k (m x)))
            ((apply? x) (tk-apply x k))))

    (defun tk-apply (x k)
        (let*
            (($r (gensym 'r))
             (c `(fun (,$r) ,(k $r))))
             (tc x c)))

    ; exp* | (aexp* -> cexp) -> cexp
    (defun t*k (xs k)
        (cond
            ((nil? xs) (k nil))
            ((pair? xs) (tk (car xs) (fun (head)
                (t*k (cdr xs) (fun (tail)
                    (k (cons head tail)))))))))

    (defun cps (x)
        (cond
            ((aexp? x)  (m x))
            ((apply? x) (tc x 'halt)))))