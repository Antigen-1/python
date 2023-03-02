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

(define-data
  python-compound-type
  (lib "value.rkt" ffi/unsafe racket/list)
  (representation
   (tuple-box (box null))
   (pytuple (lambda types
              (make-ctype PyObj*
                          (lambda (v)
                            (define l (length types))
                            (define r (apply build-value types (format "(~a)" (make-string l #\N)) v))
                            (add tuple-box r)
                            r)
                          (lambda (v) (map (lambda (o t) (cast o PyObj* t)) (map-sequence-to-list values v) types)))))
   (pytupleof (lambda (type)
                (make-ctype PyObj*
                            (lambda (v)
                              (define l (length v))
                              (define r (apply build-value (make-list l type) (format "(~a)" (make-string l #\N)) v))
                              (add tuple-box r)
                              r)
                            (lambda (v)
                              (map-sequence-to-list (lambda (o) (cast o PyObj* type)) v)))))
   (list-box (box null))
   (pylistof (lambda (type)
               (make-ctype PyObj*
                           (lambda (v)
                             (let ((l (length v)))
                               (define r (apply build-value (make-list l type) (format "[~a]" (make-string l #\N)) v))
                               (add list-box r)
                               r))
                           (lambda (v)
                             (map-sequence-to-list (lambda (o) (cast o PyObj* type)) v)))))
   (pylist (lambda types
             (make-ctype PyObj*
                         (lambda (v) (let ((l (length types)))
                                       (define r (apply build-value types (format "[~a]" (make-string l #\N)) v))
                                       (add list-box r)
                                       r))
                         (lambda (v) (map (lambda (o t) (cast o PyObj* t)) (map-sequence-to-list values v) types)))))
   (dict-box (box null))
   (pydict (lambda types
             (make-ctype PyObj*
                         (lambda (v)
                           (define l (length v))
                           (define r (apply build-value (flatten types) (format "{~a}" (make-string (* 2 l) #\N)) (flatten v)))
                           (add dict-box r)
                           r)
                         (lambda (v)
                           (define cast-pair (lambda (o t) (map (lambda (o t) (cast o PyObj* t)) o t)))
                           (map cast-pair (reverse (fold-dict v (lambda (p i) (cons p i)) null)) types)))))
   (pydictof (lambda (key value)
               (make-ctype PyObj*
                           (lambda (v)
                             (define l (length v))
                             (define r (apply build-value (flatten (make-list l (list key value))) (format "{~a}" (make-string (* 2 l) #\N)) (flatten v)))
                             (add dict-box r)
                             r)
                           (lambda (v) (reverse (fold-dict v (lambda (p i) (cons (list (cast (car p) PyObj* key) (cast (cadr p) PyObj* value)) i)) null)))))))
  (abstraction))
