#lang sicp

(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp) (if (same-variable? exp var) 1 0))
        ((sum? exp)
         (make-sum (deriv (addend exp) var)
                   (deriv (augend exp) var)))
        ((product? exp)
         (make-sum
          (make-product (mutiplier exp)
                        (deriv (multiplicand exp) var))
          (make-product (deriv (multiplier exp) var)
                        (multiplicand exp))))
        ; 更多规则往这加
        (else (error "unknown expression type --DERIV" exp))))

(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp) (if (same-variable? exp var)1 0))
        (else ((get 'deriv (operator exp)) (operands exp)
                                           var))))


;; a: 谓词并不是分支结构所需要的"操作"函数,是固定操作

;; b  procedure

(define (install-sum-package)
  ;; internal procedures
  ;;防止整个程序的procedure重名
  (define (addend s) (car s))
  (define (augend s) (cadr s))
  (define (make-sum x y)
    (cond ((=number? x 0) y)
          ((=number? y 0) x)
          ((and (number? x) (number? y))
           (+ x y))
          (else (attach-tag '+ x y))))
  ;; interface to the rest of the system
  (put 'addend '+ addend)
  (put 'augend '+ augend)
  (put 'make-sum '+ make-sum)
  (put 'deriv '+
       (lambda(exp var)
         (make-sum (deriv (addend exp) var)
                   (deriv (augend exp) var))))
  'done)

(define (make-sum x y) ((get 'make-sum '+) x y))
(define (addend sum) ((get 'addend '+)(contents sum)))
(define (augend sum) ((get 'augend '+)(contents sum)))

(define (install-exponentiation-package)
  ;; internal procedures
  (define (base exp) (car exp))
  (define (exponent exp)(cadr exp))
  (define (make-exponentiation base n)
    (cond ((= n 0) 0)
          ((= n 1) base)
          (else (attach-tag '** base n))))
  ;; interface to the rest of the system
  (put 'base '** base)
  (put 'exponent '** base)
  (put 'make-exponentiation '** make-exponentiation)
  ;; 递归版本的乘积
  (put 'deriv '**
       (lambda (exp var)
         (let ((n (exponent exp))
               (u (base exp)))
           (make-product
            n
            (make-product
             (make-exponentiation
              u
              (- n 1))
             (deriv u var))))))
  'done)





























