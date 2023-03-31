#lang sicp

(define (make-from-real-imag x y)
  (define (dispatch op)
    (cond ((eq? op 'real-part) x)
          ((eq? op 'imag-part) y)
          ((eq? op 'magnitude')
           (sqrt (+ (sqare x) (square y))))
          ((eq? op 'angle) (atan y x))
          (else
           (error "Unknown op -- MAKE-FROM-REAL-IMAG" op))))
  dispatch)

(define (apply-generic op arg) (arg op))

;; procedure
(define (make-from-mag-ang)
  (define (dispatch op)
    (cond ((eq? op 'real-part)
           (* x (cos y)))
          ((eq? op 'imag-part)
           (* x (sin y)))
          ((eq? op 'magnitude) x)
          ((eq? op 'angle) y)
          (else (error "Unknown op -- MAKE-FROM-MAG-ANG" op))))
  dispatch)






