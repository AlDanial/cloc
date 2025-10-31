;; Test fixture for Clarity language
;; This file covers various comment and code patterns

(define-constant TEST_CONSTANT u100)

;; Full line comment before code
(define-read-only (test-function (param uint))
  (ok param)
)

;; Another comment
(define-map test-map
  uint
  bool
)

(define-public (public-function)
  ;; Inline comment in function
  (begin
    ;; Nested comment
    (ok true)
  )
)

;; Trailing comment on code line
(define-data-var counter uint u0) ;; end of line comment

;; Multiple blank lines above

(define-constant ANOTHER_CONSTANT u200)

