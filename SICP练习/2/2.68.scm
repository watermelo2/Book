#lang sicp

(define (encode-symbol symbol tree)
  (cond ((leaf? tree) '())  ; 如果已经到达叶子节点,那么停止累积
        ((symbol-in-tree? symbol (left-branch tree)) ; 符号在左分支,组合 0,X
         (cons 0 (encode-symbol symbol (left-branch tree))))
        ((symbol-in-tree? symbol (right-branch tree)) ; 符号在右分支,组合 1,x
         (cons 1 (encode-symbol symbol (right-branch tree))))
        (else (error "This symbol not in tree: " symbol))))

;; find precedure: find predicate list
;; 参考文档: https://www.gnu.org/software/mit-scheme/documentation/stable/mit-scheme-ref/Searching-Lists.html
(define (symbole-in-tree? given-symbol tree)
  (not
   (false?
    (find (lambda(s)
            (eq? s given-symbol))
          (symboles tree)))))





