#lang sicp

;; procedure

(define (equals? a b)
  (= a b))

(define (element-of-set? x set)
  (cond ((null? set) false)
        ((equals? x (car set)) true)
        (else element-of-set? x (cdr set))))

(define (adjoin-set x set)
  (if (element-of-set? x set)
      set
     (cons x set)))

(define (intersection-set set1 set2)
  (cond ((or (null? set1) (null? set2)) '())
         ((element-of-set? (car set1) set2)
          (cons (car set1)
                (intersection-set (cdr set1) set2)))
         (else (intersection-set (cdr set1) set2))))

(define (union-set set1 set2)
  (cond ((and (null? set1) (null? set2)) '())
        ((null? set1) (cons (car set2) (union-set set1 set2)))
        (else (cons (car set1) (union-set set1 set2)))))

;; 加了个去重的程序
(define (deduplication set1 result)
  (cond ((null? set1) result)
        ((element-of-set? (car set1) (duplication (cdr set1) result)))
        (else adjoin-set (car set1) result)))


