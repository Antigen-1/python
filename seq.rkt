#lang racket/base
(require data-abstraction racket/runtime-path "module.rkt" "lazy.rkt")

(define-runtime-path mod-path "py")

(set-python-path (path->string (path->complete-path mod-path)))

(define seq-lib (import "seq"))

(define-data
  python-sequence
  (lib "init.rkt" "value.rkt" ffi/unsafe racket/function racket/promise "err.rkt")
  (representation
   (python-sequence? (get-ffi-obj 'PySequence_Check
                                  python-lib
                                  (_fun PyObj* -> (r : _int) -> (= r 1))
                                  (thunk (error "python-sequence?:cannot be extracted"))))
   (seq:add-to-last (lazy-load (get-object-by-name seq-lib 'add_item) (s v)))
   (seq:last (lazy-load (get-object-by-name seq-lib 'last) (s)))
   (seq:others (lazy-load (get-object-by-name seq-lib 'others) (s)))
   (nil (build-value null "[]"))
   (nil? (compose true? (lazy-load (get-object-by-name seq-lib 'nilp) (s)))))
  (abstraction
   (seq:reverse (lambda (seq) (let loop ((seq seq) (result nil))
                                (cond ((nil? seq) result)
                                      (else (loop (seq:others seq) (seq:add-to-last result (seq:last seq))))))))
   (seq:map (lambda (proc seq) 
              (let loop ((seq seq) (result nil))
                (cond ((nil? seq) (seq:reverse result))
                      (else (loop (seq:others seq) (seq:add-to-last result (proc (seq:last seq)))))))))))
