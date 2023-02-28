#lang racket/base
(require "init.rkt" "value.rkt" "func.rkt" racket/promise racket/list (for-syntax racket/base))
(provide lazy-load)

;;以下函数不增加传入对象的引用计数 
(define build-args (lambda args (let ((l (length args)))
                                  (apply build-value (make-list l PyObj*) (format "(~a)" (make-string l #\N)) args))))
(define build-kwargs (lambda (kwargs)
                       (if (null? kwargs)
                           #f
                           (let ((l (length kwargs)))
                             (apply build-value (make-list (* 2 l) PyObj*) (format "{~a}" (make-string (* 2 l) #\N)) (foldr append null kwargs))))))

;;考虑到python函数对象被封装后不可获得，以下宏会窃取其一个引用计数，请务必保证其引用计数为一
(define-syntax-rule (lazy-load body (arg ...))
  (let ((promise (delay (let ((proc body))
                          (at-exit (lambda () (void (decrement-reference proc))))
                          proc))))
    (lambda (arg ... #:kwargs (kwargs null)) (call-python-function (force promise) (build-args arg ...) (build-kwargs kwargs)))))
