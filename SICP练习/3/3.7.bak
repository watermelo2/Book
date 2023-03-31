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
                  (else
                    (error "Unknow request -- MAKE-ACCOUNT" mode)))
            display-wrong-password-message))                            
    dispatch)


