#lang sicp

;; 递归版
(define (factorial n)
  (if (= n 1)
      1
      (* n (factorial (- n 1)))))


;; 迭代版
(define (factorial n) (fact-iter 1 1 n))
(define (fact-iter product counter max-count)
  (if (> count max-count)
      product
      (fact-iter (* counter product)
                 (+ counter 1)
                 max-count)))


;; 区别: 递归版是在最低层计算值后一层层往上返回的; 迭代版是在最高层计算值后一层层往下传的






































