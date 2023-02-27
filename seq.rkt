#lang racket/base
(require data-abstraction racket/runtime-path "value.rkt")

(define-runtime-path mod-path "py")

(set-python-path (path->string (path->complete-path mod-path)))

(define-data
  python-sequence
  (lib "init.rkt" ffi/unsafe racket/function racket/promise "err.rkt" "lazy.rkt" "module.rkt")
  (representation
   (seq-lib (delay (import "seq")))
   (python-sequence? (get-ffi-obj 'PySequence_Check
                                  python-lib
                                  (_fun PyObj* -> (r : _int) -> (= r 1))
                                  (thunk (error "python-sequence?:cannot be extracted"))))
   (seq:add-to-last (lazy-load (get-object-by-name (force seq-lib) 'add_item) (s v)))
   (seq:last (lazy-load (get-object-by-name (force seq-lib) 'last) (s)))
   (seq:others (lazy-load (get-object-by-name (force seq-lib) 'others) (s)))
   (make-nil (thunk (build-value null "[]")))
   (nil? (compose true? (lazy-load (get-object-by-name (force seq-lib) 'nilp) (s)))))
  (abstraction
   (seq:reverse (lambda (seq) (let loop ((seq seq) (result (make-nil)))
                                (cond ((nil? seq) result)
                                      (else
                                       (define others (seq:others seq))
                                       (define last (seq:last seq))
                                       (dynamic-wind void
                                                     (lambda () (loop others (seq:add-to-last result last)))
                                                     (lambda () (map decrement-reference (list others last result)))))))))
   (seq:map (lambda (proc seq) 
              (let loop ((seq seq) (result (make-nil)))
                (cond ((nil? seq) (seq:reverse result))
                      (else
                       (define others (seq:others seq))
                       (define last (seq:last seq))
                       (dynamic-wind void 
                                     (lambda () (loop others (seq:add-to-last result (proc last))))
                                     (lambda () (map decrement-reference (list others last result)))))))))))
