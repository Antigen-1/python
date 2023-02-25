#lang racket/base
(require data-abstraction)

(define-data
  python-object
  (lib racket/function ffi/unsafe "init.rkt" "value.rkt")
  (representation
   (has-attribute? (get-ffi-obj 'PyObject_HasAttrString
                                python-lib
                                (_fun PyObj* _symbol -> _bool)
                                (thunk (error "has-attribute?:cannot be extracted"))))
   (get-attribute (get-ffi-obj 'PyObject_GetAttrString
                               python-lib
                               (_fun PyObj* _symbol -> (r : PyObj*) -> (if r r (error "fail to get the attribute")))
                               (thunk (error "get-attribute:cannot be extracted"))))
   (set-attribute (get-ffi-obj 'PyObject_SetAttrString
                               python-lib
                               (_fun PyObj* _symbol PyObj* -> (r : _int) -> (if (zero? r) (void) (error "fail to set the attribute")))))
   )
  (abstraction
   (check-and-handle-attribute
    (lambda (obj attr proc) (if (has-attribute? obj attr) (proc obj attr) #f)))))
