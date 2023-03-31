#lang sicp

(define (show x)
  (display-line x)
  x)

;; 打印0~10(在Racket中是这么打印的)
(define x (stream-map show (stream-enumerate-internal 0 10)))
;; 4
(stream-ref x 5)
;; 6
(stream-ref x 7)

