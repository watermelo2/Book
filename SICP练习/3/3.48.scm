#lang sicp

(define (make-account balance)
  (let ((id (generate-account-id)))
    (display id))
  )

(define (count)
    (let ((i 0))
      (lambda()
        (set! i (+ 1 i))
        i)))

(define (generate-account-id) (count))

(define cc generate-account-id)
(define foo (cc))
(foo)
(foo)
(foo)


(define (serialized-exchange acc-1 acc-2)
  (if (< (acc-1 'id) (acc-2 'id))
      (serialized-and-exchange acc-1 acc-2)
      (serialized-and-exchange acc-2 acc-1)))

(define (serialized-and-exchange smaller-id-account bigger-id-account)
  (let ((smaller-serializer (siamller-id-account 'serializer)))
    ((let ((bigger-serializer (bigger-id-account 'serializer)))
       smaller-id-account
       bigger-id-account))))

