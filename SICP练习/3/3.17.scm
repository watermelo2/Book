#lang sicp

(define (count-pairs x) (length (inner x '())))
;; memq: https://www.gnu.org/software/mit-scheme/documentation/stable/mit-scheme-ref/Searching-Lists.html#index-memq
;; 用于检查给定序对是否存在于记录列表内
(define (inner x memo-list)
  (if (and (pair? x)
           (false? (memq x memo-list)))
      (inner (car x)
             (inner (cdr x)
                    (cons x memo-list)))
      memo-list))




