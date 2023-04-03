#lang sicp

(define (let? expr) (tagged-list? expr 'let))
(define (let-vars expr) (map car (cadr expr)))
(define (let-inits expr) (map cadr (cadr expr)))
(define (let-body expr) (cddr expr))

(define (let->combination expr)
  (list (make-lambda (let-vars expr) (let-body expr))
        (let-inits expr)))

;; in eval,add this:
;; ((let? expr) (eval (let->combination expr) env))