#lang sicp

(define (pairs s t)
  (cons-stream ;; 注意,一定要有<cons-stream>否则它会被立即求值
   (list (stream-car s) (stream-car t))
   (
    interleave
    (stream-map (lambda(x) (list (stream-car s) x))
                (stream-cdr t))
    (paris (stream-cdr s) t))))

(define (interleave s1 s2)
  (if (stream-null? s1)
      s2
      (cons-stream (stream-car s1)
                   (interleave s2 (stream-cdr s1)))))
