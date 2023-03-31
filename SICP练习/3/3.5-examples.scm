#lang sicp

;; (stream-car (cons-stream x y)) = x
;; (stream-cdr (cons-stream x y)) = y

;; 取流的第N项值
(define (stream-ref s n)
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))

;; 对于流s的每项都应用proc函数
(define (stream-map proc s)
  (if (stream-null? s)
      the-empty-stream
      (cons-stream (proc (stream-car s))
                   (stream-map proc (stream-cdr s)))))

;; 
(define (stream-for-each proc s)
  (if (stream-null? s)
      'done
      (begin (proc (stream-car s))
             (stream-for-each proc (stream-cdr s)))))

;; "delay <exp>",返回延迟对象
;; "force <delay exp>"立即求职delay延迟对象
;; (cons-stream <a> <b>) == (cons <a> (delay <b>))

(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))

(define (stream-filter pred stream)
  (cond ((stream-null? stream) the-empty-stream)
        ((pred (stream-car stream))
         (cons-stream (stream-car stream)
                      (stream-filter pred
                                     (stream-cdr stream))))
        (else (stream-filter pred (stream-cdr stream)))))

(define (delay object) (lambda() (object)))
(define (force delayed-object) (delayed-object))
(define (memo-proc proc)
  (let ((already-run? false) (result false))
    (lambda()
      (if (not already-run?)
          (begin (set! result (proc))
                 (set! already-run? true)
                 result)
          result))))


(define (scale-stream stream factor)
  (stream-map
   (lambda (x) (* x factor))
   stream))

(define (add-streams s1 s2) 
  (stream-map + s1 s2))




