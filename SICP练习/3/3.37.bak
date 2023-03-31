#lang sicp

(define (c+ x y)
  (let ((sum (make-connector)))
    (adder x y sum)
    sum))

(define (c- x y)
  (let ((diff (make-connector)))
    (adder y diff x)
    diff))

(define (c* x y)
  (let ((product (make-connector)))
    (multiplier x y product)
    product))

;;略

