#lang racket/base
(require data-abstraction)

(define-data
  python-concurrency
  (lib "value.rkt")
  (representation
   (cleanup-box (make-thread-cell #f #f))
   (add (lambda (v) (let ((b (thread-cell-ref cleanup-box)))
                      (if b
                          (set-box! b (cons v (unbox b)))
                          (thread-cell-set! cleanup-box (box (list v))))
                      v)))
   (clear (lambda ()
            (let ((b (thread-cell-ref cleanup-box)))
              (if b
                  (begin (map decrement-reference (unbox b)) (set-box! b null))
                  (thread-cell-set! cleanup-box (box null)))))))
  (abstraction
   (run-and-clear (lambda (proc)
                    (dynamic-wind
                      void
                      proc
                      clear)))))
