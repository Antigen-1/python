#lang racket/base
(require data-abstraction)

(define pylib (ref-in-space python-vm:representation python-lib))

(define-data
  python-value
  (lib
   racket/base
   racket/function
   ffi/unsafe
   (only-in '#%foreign ffi-call)
   (only-in (only-space-in python-vm:representation "init.rkt")
            python-lib))
  (representation
   (PyObj* (_cpointer/null 'PyObject))
   
   (build-value
    (let ((func (ffi-obj-ref 'Py_BuildValue pylib (thunk (error "build-value:cannot be extracted")))))
      (lambda (other-input-types fmt . data) (apply (ffi-call func (cons _string other-input-types) PyObj*) fmt data))))
   
   (is? (get-ffi-obj 'Py_Is
                     pylib
                     (_fun PyObj* PyObj* -> _bool)
                     (thunk (error "is?:cannot be extracted"))))
   (none? (get-ffi-obj 'Py_IsNone
                       pylib
                       (_fun PyObj* -> _bool)
                       (thunk (error "none?:cannot be extracted"))))
   (true? (get-ffi-obj 'Py_IsTrue
                       pylib
                       (_fun PyObj* -> _bool)
                       (thunk (error "true?:cannot be extracted"))))
   (false? (get-ffi-obj 'Py_IsFalse
                        pylib
                        (_fun PyObj* -> _bool)
                        (thunk (error "false?:cannot be extracted")))))
  (abstraction))
