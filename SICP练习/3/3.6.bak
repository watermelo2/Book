#lang sicp

(define random-init 1)

(define rand
  (let ((state random-init))
    (lambda(mode)
      (cond ((eq? mode 'generate)
             (random state))
            ((eq? mode 'reset)
             (lambda(new-value)
               (set! state new-value)
               state))
            (else
             (error "Unknown mode -RAND" mode))))))


