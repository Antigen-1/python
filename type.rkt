#lang racket/base
(require data-abstraction "value.rkt" "thread.rkt")

;;此模块应与lazy.rkt配合使用来使用python模块中的函数
;;PyObj*的引用计数自行管理
;;而在此模块中定义的类型尽管都是其衍生类型，但是引用计数不由用户管理，而由这些类型本身和lazy-load宏共同管理
;;使用lazy.rkt和本模块定义的函数是线程安全的

(define-data
  python-basic-type
  (lib ffi/unsafe)
  (representation
   (_pyunicode (make-ctype PyObj*
                           (lambda (v) (add (build-value (list _string) "s" v)))
                           (lambda (v)
                             (if v
                                 (extract-and-remove extract-string/utf-8 v)
                                 #f))))
   (_pyssize (make-ctype PyObj*
                         (lambda (v) (add (build-value (list _ssize) "n" v)))
                         (lambda (v)
                           (if v
                               (extract-and-remove extract-ssize v)
                               #f))))
   (_pydouble (make-ctype PyObj*
                          (lambda (v) (add (build-value (list _double) "d" v)))
                          (lambda (v)
                            (if v
                                (extract-and-remove extract-double v)
                                #f)))))
  (abstraction))

(define-data
  python-compound-type
  (lib ffi/unsafe racket/list racket/function)
  (representation
   (pytuple (lambda types
              (make-ctype PyObj*
                          (lambda (v)
                            (define l (length types))
                            (add (apply build-value types (format "(~a)" (make-string l #\O)) v)))
                          (curry extract-and-remove (lambda (v) (map (lambda (o t) (cast o PyObj* t)) (map-sequence-to-list values v) types))))))
   (pytupleof (lambda (type)
                (make-ctype PyObj*
                            (lambda (v)
                              (define l (length v))
                              (add (apply build-value (make-list l type) (format "(~a)" (make-string l #\O)) v)))
                            (curry extract-and-remove (lambda (v) (map-sequence-to-list (lambda (o) (cast o PyObj* type)) v))))))
   (pylistof (lambda (type)
               (make-ctype PyObj*
                           (lambda (v)
                             (let ((l (length v)))
                               (add (apply build-value (make-list l type) (format "[~a]" (make-string l #\O)) v))))
                           (curry extract-and-remove (lambda (v) (map-sequence-to-list (lambda (o) (cast o PyObj* type)) v))))))
   (pylist (lambda types
             (make-ctype PyObj*
                         (lambda (v) (let ((l (length types)))
                                       (add (apply build-value types (format "[~a]" (make-string l #\O)) v))))
                         (curry extract-and-remove (lambda (v) (map (lambda (o t) (cast o PyObj* t)) (map-sequence-to-list values v) types))))))
   (pydict (lambda types
             (make-ctype PyObj*
                         (lambda (v)
                           (define l (length v))
                           (add (apply build-value (flatten types) (format "{~a}" (make-string (* 2 l) #\O)) (flatten v))))
                         (curry extract-and-remove (lambda (v) (map (lambda (o t) (list (cast (car o) PyObj* (car t)) (cast (cadr o) PyObj* (cadr t)))) (reverse (fold-dict v (lambda (p i) (cons p i)) null)) types))))))
   (pydictof (lambda (key value)
               (make-ctype PyObj*
                           (lambda (v)
                             (define l (length v))
                             (add (apply build-value (flatten (make-list l (list key value))) (format "{~a}" (make-string (* 2 l) #\O)) (flatten v))))
                           (curry extract-and-remove (lambda (v) (reverse (fold-dict v (lambda (p i) (cons (list (cast (car p) PyObj* key) (cast (cadr p) PyObj* value)) i)) null))))))))
  (abstraction))
