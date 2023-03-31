#lang sicp

;; procedure

(define x 10)
(define s (make-serializer))
(paralle-execute (lambda() (set! x ((s (lambda() (* x x))))))
                 (s (lambda() (set! x (+ x 1)))))

;; P1在<set! x n>的过程中(n是已经被计算出来的值)被P2给重新设置新值了,
;; 所以结果可能有三种: a、a、b

