#lang sicp

(define (add-assertion! assertion)
  (store-assertion-in-index assertion)
  (set! THE-ASSERTIONS
        (cons-stream assertion THE-ASSERTIONS))
  'ok)

;; 答: 会导致死循环,因为它用的是cos-stream,不会立即求值,这个流遍历的时候会死循环