#lang sicp

(define (sqrt-improve guess x)
  (average guess (/ x guess)))

;; 这个理解简单点
(define (sqrt-stream x)
  (define guesses
    (cons-stream 1.0
                 (stream-map (lambda(guess)
                               (sqrt-improve guess x))
                             guesses)))
  guesses)


(define (make-tableau transform s)
  (cons-stream s
               (make-tableau transform
                             (tramsform s))))
(define (accelerated-sequence transform s)
  (stream-map stream-car
              (make-tableau transform s)))




