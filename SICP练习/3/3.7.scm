#lang sicp

(define (make-account blance password)
    (define (withdraw amount)
        (if (>= blance amount)
            (begin (set! blance (- blance amount))
                   blance)
            "Insufficient funds"))

    (define (deposit amount)
        (set! blance (+ blance amount)))

    (define (password-match? given-password)                             
            (eq? given-password password))                             

    (define (display-wrong-password-message useless-arg)               
        (display "Incorrect password"))                                

    (define (dispatch given-password mode)          
        (if (password-match? given-password)                            
            (cond ((eq? mode 'withdraw)
                    withdraw)
                  ((eq? mode 'deposit)
                    deposit)
                  ((eq? mode 'display) blance)
                  (else
                    (error "Unknow request -- MAKE-ACCOUNT" mode)))
            display-wrong-password-message))
    dispatch)

(define (make-join origin-acc origin-password another-password)
  (define (display-wrong-another-password-message useless-arg) (display "Incorrect another password"))
  
  (lambda(given-password mode)
    (if (eq? given-password another-password)
        (origin-acc origin-password mode) ;; 注意,这里返回的是一个dispatch后的procedure
        display-wrong-another-password-message)))

(define jack-acc (make-account 100 'jack-password))
(define peter-acc (make-join jack-acc 'jack-password 'peter-password))
((peter-acc 'peter-password 'withdraw) 50)
(jack-acc 'jack-password 'display)





















