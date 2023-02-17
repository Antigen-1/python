#lang racket/base
(require data-abstraction)

(define-data
  python-value
  (lib
   racket/base
   racket/function
   ffi/unsafe
   '#%foreign
   (only-in (only-space-in python-vm:representation "init.rkt")
            python-lib))
  (representation
   (python-lib (ref-in-space python-vm:representation python-lib))
   
   (PyObj* (_cpointer/null 'PyObject))
   
   (build-value
    (let ((func (ffi-obj-ref 'Py_BuildValue python-lib (thunk (error "build-value:cannot be extracted")))))
      (lambda (other-input-types fmt . data) (apply (ffi-call func (cons _string other-input-types) PyObj*) fmt data))))
   
   (is? (get-ffi-obj 'Py_Is
                     python-lib
                     (_fun PyObj* PyObj* -> _bool)
                     (thunk (error "is?:cannot be extracted"))))
   (none? (get-ffi-obj 'Py_IsNone
                       python-lib
                       (_fun PyObj* -> _bool)
                       (thunk (error "none?:cannot be extracted"))))
   (true? (get-ffi-obj 'Py_IsTrue
                       python-lib
                       (_fun PyObj* -> _bool)
                       (thunk (error "true?:cannot be extracted"))))
   (false? (get-ffi-obj 'Py_IsFalse
                        python-lib
                        (_fun PyObj* -> _bool)
                        (thunk (error "false?:cannot be extracted")))))
  (abstraction))
