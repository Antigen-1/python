#lang racket/base
(require data-abstraction)

(define-data
  python-module
  (lib racket/function (only-in "init.rkt" python-lib) (only-in "value.rkt" PyObj*) ffi/unsafe)
  (representation
   (import (get-ffi-obj 'PyImport_ImportModule
                        python-lib
                        (_fun _string -> (r : PyObj*) -> (if r r (error "fail to import the module")))
                        (thunk (error "import:cannot be extracted"))))
   (get-object-by-name (get-ffi-obj 'PyObject_GetAttrString
                                    python-lib
                                    (_fun PyObj* _symbol -> (r : PyObj*) -> (if r r (error "fail to retreive the attribute"))))))
  (abstraction))
