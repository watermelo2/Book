#lang sicp

(define (averager a b c)
  (let ((sum (make-connector))
        (d (make-connector)))
    (adder a b sum)
    (multiplier sum d c)
    (constant (/ 1 2) d)
    'ok))
