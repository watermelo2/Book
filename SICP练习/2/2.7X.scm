#lang sicp

(define (real-part x) (car x))
(define (imag-part x) (cdr x))
(define (magnitude x)
  (sqrt (+ (square (real-part z)) (square (imag-part z)))))
(define (angle x) (atan (imag-part z) (real-part z)))

;; 返回一个采用实部和虚部描述的复数
(define (make-form-real-img x y) (cons x y))
;; 返回一个采用模和幅角描述的负数
(define (make-form-mag-ang x y) (cons (* r (cos a)) (* r (sin a))))

(define (add-complex z1 z2)
  (make-form-real-img (+ (real-part z1) (real-part z2))
                      (+ (imag-part z1) (imag-part z2))))

(define (sub-complex z1 z2)
  (make-form-real0img (- (real-part z1) (real-part z2))
                      (- (imag-part z1) (imag-part z2))))

(define (mul-complex z1 z2)
  (make-form-mag-ang (* (magnitude z1) (magnitude z2))
                     (+ (angle z1) (angle z2)))))

(define (div-complex z1 z2)
  (make-from-mag-ang (/ (magnitude z1) (magnitude z2))
                     (- (angle z1) (angle z2))))

(define (attach-tag type-tag contents) (cons type-tag contents))
(defind (type-tag datum)
  (if (pairs? datum)
      (car datum)
      (error "Bad tagged datum --TYPE-TAG" datum)))
(define (contents datum)
  (if (pairs? datum)
      (cdr datum)
      (error "Bad tagged datum --CONTENTS" datum)))
(define (rectangular? z) (eq? (type-tag z) 'rectangular'))
(define (polar? z) (eq? (type-tag z) 'polar))

(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (error
           "No Method for these types -- APPLY-GENERIC"
           (list op type-tags))))))
























