#lang sicp

;; 有6中可能返回的值
(list (amb 1 2 3) (amb 'a 'b))

;; 直接对amb求值会导致计算"失败"
(define (require p)
  (if (not p) (amb)))

(define (an-element-of items)
  (require (not (null? items)))
  (amb (car items) (an-element-of (cdr items))))

;; 返回任何一个大于或等于n的整数
(define (an-integer-starting-from n)
  (amb n (an-integer-starting-from (+ n 1))))



































