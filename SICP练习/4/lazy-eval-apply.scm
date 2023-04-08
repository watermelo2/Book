#lang sicp

(define (force-it obj)
  (if (thunk? obj)
      (actual-value (thunk-exp obj) (thunk-env obj))
      obj))
(define (delay-it exp env) (list 'thunk exp env))
(define (thunk? obj) (tagged-list? obj 'thunk))
(define (thunk-exp thunk) (cadr thunk))
(define (thunk-env thunk) (caddr thunk))
(define (actual-value exp env) (force-it (eval exp env)))

;; 加强版: 当一个槽被强迫求值时,就会将它转变为一个已求值的槽,将其中的表达式用相应
;; 的值取代,并改变其thunk标志,表示它已经是求过值的

(define (evaluated-thunk? obj) (tagged-list? obj 'evaluated-thunk))
(define (thunk-value evaluated-thunk) (cadr evaluated-thunk))
(define (force-it obj)
  (cond ((thunk? obj)
         (let ((result (actual-value
                        (thunk-exp obj)
                        (thunk-env obj))))
           (set-car! obj 'evaluated-thunk) ;; 改标记
           (set-car! (cdr obj) result) ;; 缓存结果
           (set-cdr! (cdr obj) '()) ;; 清掉不要的数据
           result))
        ((evaluated-thunk? obj)
         (thunk-value obj))
        (else obj))

(define (apply procedure arguments env)
  (cond ((primitive-procedure? procedure)
         (apply-primitive-procedure
          procedure
          (list-of-arg-values arguments env)))
        ((compound-procedure? procedure)
         (eval-sequence
          (procedure-body procedure)
          (extend-environment
           (procedure-parameters procedure)
           (list-of-delayed-args arguments env)
           (procedure-environment procedure))))
        (else
         (error "Unknown procedure type -- APPLY" procedure))))

(define (list-of-arg-values exps env)
  (if (no-operands? exps)
      '()
      (cons (actual-value (first-operand exps) env)
            (list-of-arg-values (rest-operands exps)
                                env))))

(define (list-of-deplayed-args exps env)
  (if (no-operands? exps)
      '()
      (cons (deplay-it (first-operand exps) env)
            (list-of-deplayed-args (rest-operands exps)
                                   env))))

(define (eval-if exp env)
  (if (true? (actual-value (if-predicate exp) env))
      (eval (if-consequent exp) env)
      (eval (if-alternative exp) env)))

(define input-prompt ";;; M-Eval input:")
(define output-primpt ";;; M-Eval value:")

(define (driver-loop)
  (prompt-for-input input-prompt)
  (let ((input (read)))
    (let ((output (actual-value input the-global-environment)))
      (announce-output output-prompt)
      (user-print output)))
  (driver-loop))

;; P285
(define (cons x y)
  (lambda(m) (m x y)))
(define (car z)
  (z (lambda p q) p)) 
(define (cdr z)
  (z (lambda (p q) q)))




















































