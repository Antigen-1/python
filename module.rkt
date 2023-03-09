#lang racket/base
(require data-abstraction ffi/unsafe "init.rkt" "value.rkt" (only-in "type.rkt" pydictof))

(define-cstruct
  method-def
  ((name _string) ;;_symbol does not support NULL pointer
   (func (_fun #:keep (lambda (f)
                        (define b (box f))
                        ;;deallocate the racket procedure when the python interpreter is finalized
                        (at-exit (lambda () (set-box! b #f))))
               PyObj*
               _pointer
               _ssize
               (pydictof _pyunicode PyObj*)
               ->
               PyObj*))
   (flag _int)
   (docs _string)))

(define-data
  python-module
  (lib racket/function "type.rkt" "object.rkt" "err.rkt" "lazy.rkt")
  (representation
   ;;accessor
   (import (get-ffi-obj 'PyImport_ImportModule
                        python-lib
                        (_fun _string -> (r : PyObj*) -> (if r r (check-and-handle-exception print-error)))
                        (thunk (error "import:cannot be extracted"))))
   (get-object-by-name (lambda (mod obj) (check-and-handle-attribute mod obj get-attribute)))

   ;;constructor
   (create-new-module
    (get-ffi-obj 'PyModule_New
                 python-lib
                 (_fun _symbol -> PyObj*)
                 (thunk (error "create-new-module:cannot be extracted"))))

   ;;mutator
   (meth-fastcall (make-parameter #x0080))
   (meth-keyword (make-parameter #x0002))
   (add-functions
    (get-ffi-obj 'PyModule_AddFunctions
                 python-lib
                 (_fun (m f d)
                       ::
                       (PyObj* = m)
                       ((_array/list _meth-def (add1 (length f)))
                        =
                        (append (map (lambda (f d) (make-meth-def
                                                    (symbol->string (object-name f))
                                                    (lambda (self block size kwargs)
                                                      (f self (cblock->list block PyObj* size) kwargs))
                                                    (bitwise-ior (meth-fastcall) (meth-keyword))
                                                    d))
                                     f d)
                                (list (make-meth-def #f #f 0 #f))))
                       ->
                       _int)
                 (thunk (error "add-functions:cannot be extracted"))))
   
   ;;config
   (set-python-path (let ((check-and-get (lambda (obj att) (check-and-handle-attribute obj att get-attribute))))
                      (lambda (path-string)
                        ((compose
                          decrement-reference
                          (lazy-load
                           (let* ((sys-lib (import "sys"))
                                  (path (get-object-by-name sys-lib 'path))
                                  (proc (check-and-get path 'append)))
                             (at-exit (lambda () (void (map decrement-reference (list sys-lib path)))))
                             proc)
                           (_pyunicode)
                           ()
                           PyObj*))
                          (path->string path-string))))))
  (abstraction))
