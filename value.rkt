#lang racket/base
(require data-abstraction)

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
    (let ((func (ffi-obj-ref 'Py_BuildValue (ref-in-space python-vm:representation python-lib) (thunk (error "build-value:cannot be extracted")))))
      (lambda (other-input-types fmt . data) (apply (ffi-call func (cons _string other-input-types) PyObj*) fmt data))))

   (create-strong-reference (get-ffi-obj 'Py_XNewRef
                                         (ref-in-space python-vm:representation python-lib)
                                         (_fun PyObj* -> PyObj*)
                                         (thunk (error "create-strong-reference:cannot be extracted"))))
   (reference:borrowed->strong (get-ffi-obj 'Py_XIncRef
                                            (ref-in-space python-vm:representation python-lib)
                                            (_fun (p : PyObj*) -> _void -> p)
                                            (thunk (error "reference:borrowed->strong:cannot be extracted"))))
   (decrement-reference (get-ffi-obj 'Py_DecRef
                                     (ref-in-space python-vm:representation python-lib)
                                     (_fun (p : PyObj*) -> _void -> p)
                                     (thunk (error "decrement-reference:cannot be extracted"))))
   
   (is? (get-ffi-obj 'Py_Is
                     (ref-in-space python-vm:representation python-lib)
                     (_fun PyObj* PyObj* -> _bool)
                     (thunk (error "is?:cannot be extracted"))))
   (none? (get-ffi-obj 'Py_IsNone
                       (ref-in-space python-vm:representation python-lib)
                       (_fun PyObj* -> _bool)
                       (thunk (error "none?:cannot be extracted"))))
   (true? (get-ffi-obj 'Py_IsTrue
                       (ref-in-space python-vm:representation python-lib)
                       (_fun PyObj* -> _bool)
                       (thunk (error "true?:cannot be extracted"))))
   (false? (get-ffi-obj 'Py_IsFalse
                        (ref-in-space python-vm:representation python-lib)
                        (_fun PyObj* -> _bool)
                        (thunk (error "false?:cannot be extracted")))))

  (abstraction
   ;;这些抽象的目的在于维持输入和输出时对象（在这些caller所有权下）的引用计数不变
   (call/stolen-reference
    (lambda (obj proc)
      (dynamic-wind (lambda () (create-strong-reference obj))
                    (lambda () (proc obj))
                    void)))
   (call/new-reference
    (lambda (obj proc)
      (dynamic-wind void
                    (lambda () (proc obj))
                    (lambda () (decrement-reference obj)))))))
