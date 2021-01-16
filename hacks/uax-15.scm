(use-modules (guix packages)
             (guix build lisp-utils)
             (guix build-system asdf)
             (guix download)
             (guix git-download)
             ((guix licenses) #:prefix license:)
             (gnu packages)
             (gnu packages lisp)
             (gnu packages lisp-xyz))

(define-public sbcl-uax-15
  (package
   (name "sbcl-uax-15")
   (version "0.0.0")
   (source origin...)
   (build-system asdf-build-system)
   (home-page "https://github.com/nicklevine/cl-log")
   (synopsis "Common lisp implementation of unicode normalization functions")
   (description "")
   (license )))
