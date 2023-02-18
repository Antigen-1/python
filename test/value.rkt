#lang racket/base
(module test racket/base
  (require racket/function ffi/unsafe "../init.rkt" "../value.rkt")
  
  (call-with-python-vm
   (thunk
    (let* ((v (build-value (list _pointer) "s" #f))
           (t (call/new-reference v (lambda (v) (build-value (list PyObj*) "(O)" v)))))
      (if (and (none? v)
               (is? v v))
          (displayln "successfully build a NONE")
          (dynamic-wind
            void
            (thunk (error "fail to build a NONE"))
            (thunk (decrement-reference t))))
      (if t
          (displayln "successfully build the tuple")
          (dynamic-wind void
                        (thunk (error "fail to build the tuple"))
                        (thunk (decrement-reference t))))
      (decrement-reference t)))))
