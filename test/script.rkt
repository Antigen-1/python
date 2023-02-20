#lang racket/base
(require racket/runtime-path)

(define-runtime-path script "script.py")

(module* test #f
  (require "../script.rkt"
           "../init.rkt")
  
  (call-with-python-vm (lambda ()
                         (call-with-file-structure
                          script
                          "rb"
                          (lambda (f) (run-file f script statement-sequence-symbol #f #f)))
                         (void (eval-string "print(\"simple-python-api on racket\n\")"
                                            single-statement-symbol
                                            #f
                                            #f)))))
