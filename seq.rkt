#lang racket/base
(require data-abstraction racket/runtime-path racket/promise "value.rkt" "module.rkt" "init.rkt")

(define-runtime-path mod-path "py")

(define seq-lib (delay
		  (set-python-path (path->complete-path mod-path))
		  (let ((lib (import "seq")))
                    (at-exit (lambda () (void (decrement-reference lib))))
                    lib)))

(define-data
  python-sequence
  (lib ffi/unsafe racket/function "lazy.rkt")
  (representation
   (python-sequence? (get-ffi-obj 'PySequence_Check
                                  python-lib
                                  (_fun PyObj* -> (r : _int) -> (= r 1))
                                  (thunk (error "python-sequence?:cannot be extracted"))))
   (seq:add-to-last (lazy-load (get-object-by-name (force seq-lib) 'add_item) (s v)))
   (seq:last (lazy-load (get-object-by-name (force seq-lib) 'last) (s)))
   (seq:others (lazy-load (get-object-by-name (force seq-lib) 'others) (s)))
   (make-nil (lazy-load (get-object-by-name (force seq-lib) 'make_nil) ()))
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
		       (define last-result (proc last-result))
                       (dynamic-wind void 
                                     (lambda () (loop others (seq:add-to-last result last-result)))
                                     (lambda () (map decrement-reference (list others last last-result result)))))))))))
