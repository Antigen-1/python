#lang racket/base
(require data-abstraction)

(define-data
  python-basic-type
  (lib "value.rkt" ffi/unsafe)
  (representation
   (unicode-box (box null))
   (ssize-box (box null))
   (double-box (box null))
   (clear (lambda (b) (map decrement-reference (unbox b)) (set-box! b null)))
   (add (lambda (b v) (set-box! b (cons v (unbox b)))))
   (_pyunicode (make-ctype PyObj*
                           (lambda (v) (let ((u (build-value (list _string) "s" v)))
                                         (add unicode-box u)
                                         u))
                           (lambda (v)
                             (if v
                                 (let ((s (extract-string/utf-8 v)))
                                   (decrement-reference v)
                                   s)
                                 #f))))
   (_pyssize (make-ctype PyObj*
                         (lambda (v) (let ((s (build-value (list _ssize) "n" v)))
                                       (add ssize-box s)
                                       s))
                         (lambda (v)
                           (if v
                               (let ((i (extract-ssize v)))
                                 (decrement-reference v)
                                 i)
                               #f))))
   (_pydouble (make-ctype PyObj*
                          (lambda (v) (let ((d (build-value (list _double) "d" v)))
                                        (add double-box d)
                                        d))
                          (lambda (v)
                            (if v
                                (let ((f (extract-double v)))
                                  (decrement-reference v)
                                  f)
                                #f)))))
  (abstraction))
