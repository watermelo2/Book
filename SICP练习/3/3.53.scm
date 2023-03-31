#lang sicp

(define (stream-map proc s)
  (if (stream-null? s)
      the-empty-stream
      (cons-stream (proc (stream-car s))
                   (stream-map proc (stream-cdr s)))))
(define (add-streams s1 s2) (stream-map + s1 s2))
(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))

(define s (cons-stream 1 (add-streams s s)))

(define (stream-for-each proc s)
  (if (stream-null? s)
      'done
      (begin (proc (stream-car s))
             (stream-for-each proc (stream-cdr s)))))
;; 2N
(stream-for-each display s)


