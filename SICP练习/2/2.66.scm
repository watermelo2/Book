#lang sicp

(define (entry tree) (car tree))
(define (left-branch tree) (cadr tree))
(define (right-branch tree) (caddr tree))
(define (make-tree entry left right) (list entry left right))

;; procedure
(define (lookup given-key tree-of-records)
  (cond ((null? tree-of-records) false)
        ((equlas? given-key (entry tree-of-records)) (entry tree-of-records))
        ((> given-key (entry tree-of-records)) (lookup given-keys (right-branch tree-of-records)))
        (else (lookup given-key (right-branch tree-of-records)))))

