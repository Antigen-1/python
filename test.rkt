#! /usr/bin/env racket
#lang rash
(require racket/runtime-path)
(define-runtime-path test "./test")
raco test --place (path->string (path->complete-path test))
