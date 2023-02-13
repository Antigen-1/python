#lang racket/base
(require data-abstraction (for-syntax racket/base))

(define-data
  python-vm
  (ffi/unsafe racket/function)
  ((initialize (get-ffi-obj "Py_Initialize" python-lib (_fun -> _void) (thunk (error "initialize:cannot be extracted"))))
   (finalize (get-ffi-obj "Py_FinalizeEx" python-lib (_fun -> (r : _int) -> (if (zero? r) (void) (error "finalize:fail to free all memory allocated by python"))) (thunk (error "finalize:cannot be extracted"))))
   (initialized? (get-ffi-obj "Py_IsInitialized" python-lib (_fun -> (r : _int) -> (if (zero? r) (error "initialized?:the python vm is not initialized successfully") (void))) (thunk (error "initialized?:cannot be extracted")))))
  ((call-with-python-vm (lambda (proc)
                          (initialize)
                          (initialized?)
                          (dynamic-wind void proc finalize)))))
(require 'python-vm)
(provide (all-from-out 'python-vm))
