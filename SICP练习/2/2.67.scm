#lang sicp

;; 左分支  PS: 'leaf 是一个特殊符号(标记)
(define (make-leaf symbol weight) (list 'leaf  symbol weight))
;; 右分支
(define (leaf? object) (eq? (car object) 'leaf))
;; 符号集合
(define (symbol-leaf x) (cadr x))
;; 权重
(define (weight-leaf x) (caddr x))

;; 一棵一般的赫夫曼树就是一个表,包含 左分支、右分支、符号集合、权重

(define (make-code-tree left right)
  (list left
        right
        (append (symbols left) (symbols right))
        (+ (weight left) (weight right))))


(define (left-branch tree) (cadr tree))
(define (right-branch tree) (caddr tree))
(define (symbols tree)
  (if (leaf? tree)
      (list (symbol-leaf tree))
      (caddr tree))) ;; PS 注意,这是用列表表示的树,其实更应该叫 treeNode 更好理解
(define (weight tree)
  (if (leaf? tree)
      (weight-leaf tree)
      (caddr tree)))

(define (decode bits tree)
  (define (decode-1 bits current-branch)
    (if (null? bits)
        '()
        (let ((next-branch
               (choose-branch (car bits) current-branch)))
          (if (leaf? next-branch)
              (cons (symbol-leaf next-branch)
                    (decode-1 (cdr bits) tree))
              (decode-1 (cdr bits) next-branch)))))
  (decode-1 bits tree))

(define (choose-branch bit branch)
  (cond ((= bit 0) (left-branch branch))
        ((= bit 1) (right-branch branch))
        (else (error "bad bit -- CHOOSE-BRANCH" bit))))

;; 有点像 adjoin-set ,但这里比的是权重(weight)
(define (adjoin-set x set )
  (cond ((null? set) (list x))
        ((< (weight x) (weight (car set))) (cons x set))
        (else (cons (car set)
                    (adjoin-set x (cdr set))))))
 
;; 一个按权重排序函数
(define (make-leaf-set pairs)
  (if (null? pairs)
      '()
      (let ((pair (car pairs)))
        (adjoin-set (make-leaf (car pair)
                               (cadr pair))
                    (make-leaf-set (cdr pairs))))))

;; procedure

(define sample-tree
  (make-code-tree (make-leaf 'A 4)
                  (make-code-tree
                   (make-leaf 'B 2)
                   (make-code-tree (make-leaf 'D 1)
                                   (make-leaf 'C 1)))))
(define sample-message '(0 1 1 0 0 1 0 1 0 1 1 1 0))

;; result: AD AB B C A (看的答案)

