#lang sicp

(define f
  (lambda(first)
    (set! f (lambda(second) 0))
    first))
