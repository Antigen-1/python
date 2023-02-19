#lang racket/base
(require data-abstraction)

(define-data
  file-structure
  (lib ffi/unsafe)
  (representation
   (c-runtime (ffi-lib #f))
   (FILE* (_cpointer 'FILE))
   (fopen (get-ffi-obj 'fopen
                       c-runtime
                       (_fun _file _string -> FILE*)
                       (thunk (error "fopen:cannot be extracted"))))
   (fclose (get-ffi-obj 'fclose
                        c-runtime
                        (_fun FILE* -> (r : _int) -> (if (zero? r) (void) (error "fail to close the file")))
                        (thunk (error "fclose:cannot be extracted")))))
  (abstraction
   (call-with-file-structure
    (lambda (file mode proc)
      (define file-structure (fopen file mode))
      (dynamic-wind void
                    (lambda () (proc file-structure))
                    (lambda () (fclose file-structure)))))))
