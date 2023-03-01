#lang racket/base
(require data-abstraction)

(define-data
  python-value
  (lib
   racket/function
   ffi/unsafe
   (only-in '#%foreign ffi-call)
   "err.rkt"
   "init.rkt")
  (representation
   (PyObj* (_cpointer/null 'PyObject))
   
   (build-value
    (let ((func (ffi-obj-ref 'Py_BuildValue python-lib (thunk (error "build-value:cannot be extracted")))))
      (lambda (other-input-types fmt . data) (apply (ffi-call func (cons _string other-input-types) PyObj*) fmt data))))

   (extract-ssize (get-ffi-obj 'PyLong_AsSsize_t
                               python-lib
                               (_fun PyObj* -> (r : _ssize) -> (if (and (= r -1) (error-occurred?))
                                                                   (print-error)
                                                                   r))
                               (thunk (error "extract-ssize:cannot be extracted"))))
   (extract-double (get-ffi-obj 'PyFloat_AsDouble
                                python-lib
                                (_fun PyObj* -> (r : _double)
                                      -> (if (and (= r -1.0) (error-occurred?))
                                             (print-error)
                                             r))
                                (thunk (error "extract-double:cannot be extracted"))))
   (extract-string/utf-8 (get-ffi-obj 'PyUnicode_AsUTF8
                                      python-lib
                                      (_fun PyObj* -> (r : _string)
                                            -> (if r r (check-and-handle-exception print-error)))
                                      (thunk (error "extract-string/utf-8:cannot be extracted"))))

   (create-strong-reference (get-ffi-obj 'Py_XNewRef
                                         python-lib
                                         (_fun PyObj* -> PyObj*)
                                         (thunk (error "create-strong-reference:cannot be extracted"))))
   (reference:borrowed->strong (get-ffi-obj 'Py_IncRef
                                            python-lib
                                            (_fun (p : PyObj*) -> _void -> p)
                                            (thunk (error "reference:borrowed->strong:cannot be extracted"))))
   (decrement-reference (get-ffi-obj 'Py_DecRef
                                     python-lib
                                     (_fun (p : PyObj*) -> _void -> p)
                                     (thunk (error "decrement-reference:cannot be extracted"))))
   
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
