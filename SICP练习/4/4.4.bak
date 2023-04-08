#lang sicp

;; install eval expressions
(defineoperation-table make-table)
(define get (operation-table 'lookup-proc))
(define put (operation-table 'insert-proc))

(put 'eval 'and eval-and)
(put 'eval 'or eval-or)

;; and逻辑: 从左到右求值,如果某个表达式求出的值是假,那么就返回值,剩下的表达式也不再求值. 如果所有的表达式求出的值
;; 都是真的,那么就返回最后一个表达式的值. 如果没有可求值的表达式就返回真
(define (eval-and exps env)
  (cond ((null? exps) #t)
        ((last-exp? (first-exp exps))
         (eval (firsst-exp exps)))
        ((true? (eval (first-exp exps) env))
         (eval-and (rest-exp exps) env))
        (else #f)))

;; or逻辑: 从左到右求值,如果某个表达式求出的值是真,那么就返回真值,剩下的表岛是也不再求值.
;; 如果所有的表达式求出的值都是假,或者根本就没有可求值的表达式,那么返回表达式
(define (eval-or exps env)
  (cond ((null? exps) #f)
        ((true? (eval (first-exp exps) env))
         (eval-or (rest-exp exps) env))
        (else (eval-or (rest-exp exps) env))))
