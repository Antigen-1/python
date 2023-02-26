#lang racket/base
(require data-abstraction)

(define-data
  python-vm
  (lib ffi/unsafe racket/function "lib.rkt")
  (representation
   (python-lib (get-python-lib))
   (initialize (get-ffi-obj "Py_Initialize" python-lib (_fun -> _void) (thunk (error "initialize:cannot be extracted"))))
   (finalize (get-ffi-obj "Py_FinalizeEx" python-lib (_fun -> (r : _int) -> (if (zero? r) (void) (error "finalize:fail to free all memory allocated by python"))) (thunk (error "finalize:cannot be extracted"))))
   (at-exit (get-ffi-obj "Py_AtExit" python-lib (_fun (_fun -> _void) -> (r : _int) -> (if (zero? r) (void) (error "fail to cleanup")))))
   (initialized? (get-ffi-obj "Py_IsInitialized" python-lib (_fun -> _bool) (thunk (error "initialized?:cannot be extracted")))))
  (abstraction
   (call-with-python-vm (lambda (proc)
                          (initialize)
                          (if (initialized?) (void) (error "fail to initialize the python vm"))
                          (dynamic-wind void proc finalize)))))
