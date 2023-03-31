#lang sicp

(define balance 100)

;; set!语法: set! <name> <new-value>
;; begin语法: begin <exp1> <exp2> ...;将表达式顺序求值,最后一个表达式的值为作为整个begin形式的值返回
(define (withdraw amount)
  (if (>= balance amount)
      (begin (set! balance (- balance amount))
             balance)
      "Insufficient funds"))
(define new-withdraw
  (let ((balance 100))
    (lambda(amount)
      (if (>= balance amount)
          (begin (set! balance (- balance amount))
                 balance)
          "Insufficient funds"))))

(define (make-withdraw balance)
  (lambda(amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount))
               balance)
        "Insufficient funds")))

(define W1 (make-withdraw 100))

(W1 50)
(W1 60)









