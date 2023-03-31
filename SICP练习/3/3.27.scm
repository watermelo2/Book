#lang sicp

(define (fib n)
  (cond ((= n 0) 0)
        ((= n 1) 1)
        (else (+ (fib (- n 1))
                 (fib (- n 2))))))

(define memo-fib
  (memoize (lambda(n)
             (cond ((= n 0) 0)
                   ((= n 1) 1)
                   (else (+ (memo-fib (- n 1))
                            (memo-fib (- n 2))))))))

(define (memoize f)
  (let ((table (make-table)))
    (lambda (x)
      (let ((pre-result (lookup x table)))
        (or pre-result
            (let ((result (f x)))
              (inert! x result table)
              result))))))


;; 如果简单定义为 (define x memo-fib(memoize fib)) 的话,能工作,但效率没有提升,因为缓存被定义为x的局部变量了

