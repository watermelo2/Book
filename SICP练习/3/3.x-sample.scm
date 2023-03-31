#lang sicp

(define (multiplier m1 m2 product)
  (define (process-new-value)
    (cond ((or (and (has-value? m1) (= (get-value m1) 0))
               (and (has-value? m2) (= (get-value m2) 0)))
           ((and (has-value? m1) (xxx))))))

  (define (process-forget-value)
    (forget-value! product me)
    (forget-value! m1 me)
    (forget-value! m2 me)
    (process-new-value))
  
  (define (me request)
    (cond ((eq? request 'I-have-a-value)
           (process-new-value))
          ((eq? request 'I-lost-my-value)
           (process-forget-value))
          (else
           (error "Unknown xxxx"))))

  (connect m1 me)
  (connect m2 me)
  (connect product me)
  
  me)

(define foo 1)
(define bar 2)
(define res)
(define res-product-procedure (multiplier foo bar (lambda(x,y) (* x y))))
(res-product-procedure 'I-have-a-value)
(display (get-value res-product-procedure))


