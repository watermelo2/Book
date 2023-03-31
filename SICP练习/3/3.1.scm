#lang sicp

(define (make-accumulator base)
  (lambda(add)
    (begin (set! base (+ base add))
           base)))

(define A (make-accumulator 5))
(A 10)
(A 10)

