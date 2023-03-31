#lang sicp

;; 将扫描过的数据在remain-list的每个元素的car中插入一个标识(表示扫描过它)
(define (loop? lst)
  (let ((identity (cons '() '())))
    (define (iter remain-list)
      (cond ((null? remain-list)
             #f)
            ((eq? identity (car remain-list))
             #t)
            (else
             (set-car! remain-list identity)
             (iter (cdr remain-list)))))
    (iter lst)))




























