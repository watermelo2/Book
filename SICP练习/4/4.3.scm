#lang sicp

;; install eval expressions
(defineoperation-table make-table)
(define get (operation-table 'lookup-proc))
(define put (operation-table 'insert-proc))

(put 'eval 'quote text-of-quotation)
(put 'eval 'set! eval-assignment)
(put 'eval 'define eval-definition)
(put 'eval 'if eval-if)
(put 'eval 'lambda (lambda(x y)
                   (make-procedure (lambda-parameters x) (lambda-body x) y)))
(put 'eval 'begin (lambda(x y)
                  (eval-sequence (begin-sequence x) y)))
;; 这里结合前面讲到的(cond转if的那段代码理解)
(put 'eval 'cond (lambda(x y)
                 (evaln (cond->if x) y)))



;; eval procedure
(define (evaln expr env)
  (cond ((self-evaluating? expr) expr)
        ((variable? expr) (lookup-variable-value expr env))
        ((get 'eval (operator expr)) (apply (get 'eval (operator expr)) env))
        ((application? expr)
         (applyn (evaln (operator expr) env)
                 (list-of-values (operands expr) env)))
        (else (error "Unknown expression type -- EVAL" expr))))



