#lang sicp

(define (generate-huffman-tree pairs)
  (successive-merge (make-leaf-set pairs)))

;; 需要注意的是,ordered-set中同时存在 树、树叶
(define (successive-merge ordered-set)
  (cond ((= 0 (length ordered-set)) '())
        ((= 1 (length ordered-set)) (car ordered-set)) ;; 最后数据作为返回数据
        (else
         (let ((new-sub-tree (make-code-tree (car ordered-set)
                                             (cadr ordered-set)))
               (remained-ordered-set (cddr ordered-set)))
           (successive-merge (adjoin-set new-sub-tree remained-ordered-set))))))





