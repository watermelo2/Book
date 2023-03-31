#lang sicp
 

(define (make-queue)
  (let ((front-ptr '())
    (rear-ptr '()))
  (define (insert-queue! item)
    (cond ((empty-queue?)
           (let ((init-list (list item)))
             (set! front-ptr init-list)
             (set! rear-ptr init-list)
             front-ptr))
          (else
           (let ((new-item (list item)))
             (set-cdr! rear-ptr new-item)
             (set! rear-ptr new-item)
             front-ptr))))
  (define (delete-queue!)
    (cond ((empty-queue?)
           (error "DELETE! called with an empty queue"))
          (else
           (set! front-ptr (cdr front-ptr))
           front-ptr)))
  (define (empty-queue?) (null? front-ptr))
  (define (dispatch m)
    (cond ((eq? m 'insert-queue!) insert-queue!)
          ((eq? m 'delete-queue!) delete-queue!)
          ((eq? m 'empty-queue?) empty-queue?)
          (else (error "Unknown operation --DISPATCH" m))))
  dispatch))

