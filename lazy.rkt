#lang racket/base
(require "init.rkt" "func.rkt" "type.rkt" racket/promise (for-syntax racket/base))
(provide lazy-load)

;;考虑到python函数对象被封装后不可获得，以下宏会窃取其一个引用计数，请务必保证其引用计数为一
(define-syntax (lazy-load stx)
  (syntax-case stx ()
    ((_ body (arg ...) ((key value) ...) result)
     (with-syntax (((args ...) (map (lambda (s) (datum->syntax #'stx s)) (generate-temporaries #'(arg ...))))
                   ((kwargs ...) (map (lambda (s) (datum->syntax #'stx s)) (generate-temporaries #'(key ...)))))
       #'(let ((promise (delay (let ((p body))
                                 (at-exit (lambda () (decrement-reference p)))
                                 p))))
           (lambda (args ... kwargs ...) (call-python-function #:in (list (pytuple arg ...) (pydict (list _pyunicode value) ...)) #:out result
                                                               (force promise)
                                                               (list args ...)
                                                               (map list (list key ...) (list kwargs ...)))))))))
