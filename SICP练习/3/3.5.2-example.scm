#lang sicp

;; 这是普通序列无法做到的
(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))

(define integers (integers-starting-from 1))

(define (divisible? x y) (= (remainder x y) 0))
(define no-sevens (stream-filter (lambda(x) (not (divisible? x 7)))
                                 integers))
(define (fibgen a b)
  (cons-stream a (fibgen b (+ a b))))
(define fibs (fibegn 0 1))

;; 蛮难懂的(<stream-cdr fibs>这段不理解)
(define fibs
  (cons-stream 0
               (cons-stream 1
                            (add-stream (stream-cdr fibs)
                                        fibs))))

(define (scale-stream stream factor)
  (stream-map (lambda(x) (* x factor)) stream))

(define double (cons-stream 1 (scale-stream double 2)))






