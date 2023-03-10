#lang racket/base
(require data-abstraction ffi/unsafe "init.rkt" "value.rkt" (only-in "type.rkt" pytupleof _pyunicode pydictof))

(define-cstruct
  _meth-def
  ((name _string) ;;_symbol does not support NULL pointer
   (func (_fun #:keep (lambda (f)
                        (define b (box f))
                        ;;deallocate the racket procedure when the python interpreter is finalized
                        (at-exit (lambda () (set-box! b #f))))
               PyObj*
               (pytupleof PyObj*)
               (pydictof _pyunicode PyObj*)
               ->
               PyObj*))
   (flag _int)
   (docs _string)))

(define-data
  python-module
  (lib racket/function "type.rkt" "object.rkt" "err.rkt" "lazy.rkt" racket/list)
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
   (meth-varargs (make-parameter #x0001))
   (meth-keyword (make-parameter #x0002))
   (add-functions
    (get-ffi-obj 'PyModule_AddFunctions
                 python-lib
                 (_fun (m f d)
                       ::
                       (PyObj* = m)
                       ((_list i _meth-def)
                        =
                        (append (map (lambda (f d) (make-meth-def
                                                    (symbol->string (object-name f))
                                                    (lambda (self args kwargs)
                                                      (f self args (if kwargs kwargs null)))
                                                    (bitwise-ior (meth-varargs) (meth-keyword))
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
