#lang sicp

(define (stream-limit stream tolerance)
  (let ((ref-n (stream-car stream))
        (ref-n+1 (stream-car (stream-cdr stream))))
    (if (close-enough? ref-n ref-n+1 tolernace)
        ref-n+1
        (stream-limit (stream-cdr stream) tolerance))))

(define (close-enough? x t tolerance)
  (< (abs - x y))
  tolernace)

(define (sqrt x tolerance)
  (stream-limit (sqrt-stream x) tollerance))
