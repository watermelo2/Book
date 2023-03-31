#lang sicp

(define parallel-execute <p1> <p2> ... <pn>)
(define make-serializer <p1> <p2> ... <pn>)

;; 串行化语法
(define protected (make-serializer))
;; 此时只会产生101和121两个可能的结果,P1和P2不可能交错进行
(parallel-execute (protected (lambda() (set! x (* x x))))
                  (protected (lambda() (set! x (+ x 1)))))





