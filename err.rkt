#lang racket/base
(require data-abstraction)

(define-data
  python-error
  (lib ffi/unsafe "init.rkt" racket/function)
  (representation
   (error-occurred? (get-ffi-obj 'PyErr_Occurred
                                 python-lib
                                 ;;return either a NULL or the type of the exception (borrowed reference)
                                 (_fun -> _pointer)
                                 (thunk (error "error-occurred?:cannot be extracted"))))
   (print-error (get-ffi-obj 'PyErr_Print
                             python-lib
                             (_fun -> _void)
                             (thunk (error "print-error:cannot be extracted"))))
   (clear-error (get-ffi-obj 'PyErr_Clear
                             python-lib
                             (_fun -> _void)
                             (thunk (error "clear-error:cannot be extracted"))))
   )
  (abstraction
   (check-and-handle-exception
    (lambda (proc)
      (cond ((error-occurred?) (proc))
            (else #f))))))
