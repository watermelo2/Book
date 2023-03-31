#lang sicp

(define (make-account blance password)
  (let ((total-wrong 0)))
  
    (define (withdraw amount)
        (if (>= blance amount)
            (begin (set! blance (- blance amount))
                   blance)
            "Insufficient funds"))

    (define (deposit amount)
        (set! blance (+ blance amount)))

    (define (password-match? given-password)                             
            (eq? given-password password))
  
    (define (call-the-cops) (display "Call Cops"))
  
    (define (wrong-password useless-arg)
      (if (> (+ total-wrong 1) 7)
          (call-the-cops)
          (display "Incorrect password")))                                

    (define (dispatch given-password mode)          
        (if (password-match? given-password)                            
            (cond ((eq? mode 'withdraw)
                    withdraw)
                  ((eq? mode 'deposit)
                    deposit)
                  (else
                    (error "Unknow request -- MAKE-ACCOUNT" mode)))
            wrong-password))                            
    dispatch)


