#lang sicp

;; procedure

(define (equals? a b)
  (= a b))

(define (element-of-set? x set)
  (cond ((null? set) false)
        ((= x (car set)) true)
        ((< x (car set)) false)
        (else element-of-set? x (cdr set))))

(define (adjoin-set x set)
  (if (element-of-set? x set)
      set
     (cons x set)))

(define (adjoin-set x set)
  (cond ((null? set) (cons x '()))
        ((= x (car set)) set)
        ((< x (car set)) (adjoin-set x (cdr set)))
        (else set)))

(define (intersection-set set1 set2)
  (cond ((or (null? set1) (null? set2)) '())
         (let ((x1 (car set1)) (x2 (car set2)))
           (cond ((= x1 x2)
                  (cons x1
                        (intersection-set (cdr set1)
                                          (cdr set2))))
                 ((< x1 x2)
                  (intersection-set (cdr set1) set2))
                 ((< x2 x1)
                  (intersection-set set1 (cdr set2)))))))

(define (union-set set1 set2)
  (cond ((and (null? set1) (null? set2)) '())
        ((null? set1) (cons (car set2) (union-set set1 set2)))
        (else (cons (car set1) (union-set set1 set2)))))

;; 加了个去重的程序
(define (deduplication set1 result)
  (cond ((null? set1) result)
        ((element-of-set? (car set1) (duplication (cdr set1) result)))
        (else adjoin-set (car set1) result)))


