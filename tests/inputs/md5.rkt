#lang racket/base

(provide md5)

;;; Copyright (c) 2005-2014, PLT Design Inc.
;;; Copyright (c) 2002, Jens Axel Soegaard
;;;
;;; Distributed under the same terms as Racket, by permission.
;;;
;;; md5.scm  --  Jens Axel Soegaard, 16 oct 2002

;;; Summary
;; This is an implementation of the md5 message-digest algorithm in R5RS
;; Scheme.  The algorithm takes an arbitrary byte-string or an input port, and
;; returns a 128-bit "fingerprint" byte string.  The algorithm was invented by
;; Ron Rivest, RSA Security, INC.  Reference: RFC 1321,
;; <http://www.faqs.org/rfcs/rfc1321.html>

;;; History
;; 2002-10-14  /jas
;; - Bored. Initial attempt. Done. Well, except for faulty output.
;; 2002-10-15  /jas
;; - It works at last
;; 2002-10-16  /jas
;; - Added R5RS support
;; 2003-02-16 / lth
;; - Removed let-values implementation because Larceny has it already
;; - Implemented Larceny versions of many bit primitives (note, 0.52 or later
;;   required due to bignum bug)
;; - Removed most 'personal idiosyncrasies' to give the compiler a fair chance
;;   to inline primitives and improve performance some.  Performance in the
;;   interpreter is still really quite awful.
;; - Wrapped entire procedure in a big LET to protect the namespace
;; - Some cleanup of repeated computations
;; - Moved test code to separate file
;; 2003-02-17 / lth
;; - Removed some of the indirection, for a 30% speedup in Larceny's
;;   interpreter.  Running in the interpreter on my Dell Inspiron 4000 I get a
;;   fingerprint of "Lib/Common/bignums-be.sch" in about 63ms, which is slow
;;   but adequate.  (The compiled version is not much faster -- most time is
;;   spent in bignum manipulation, which is compiled in either case.  To do
;;   this well we must either operate on the bignum representation or redo the
;;   algorithm to use fixnums only.)
;; 2003-12-01 / lth
;; - Reimplemented word arithmetic to use two 16-bit fixnums boxed in a cons
;;   cell.  In Petit Larceny's interpreter this gives a speedup of a factor of
;;   almost eight, and in addition this change translates well to other Scheme
;;   systems that support bit operations on fixnums.  Only 17-bit (signed)
;;   fixnums are required.
;; 2003-12-23 / jas
;; - Trivial port to PLT.  Rewrote the word macro to syntax-rules.  Larceny
;;   primitives written as syntax-rules macros exanding to their PLT name.
;; 2005-05-05 / Greg Pettyjohn
;; - It was failing for strings of length 56 bytes i.e. when the length in bits
;;   was congruent 448 modulo 512.  Changed step 1 to fix this.  According to
;;   RFC 1321, the message should still be padded in this case.
;; 2005-12-23 / Jepri
;; - Mucked around with the insides to get it to read from a port
;; - Now it accepts a port or a string as input
;; - Doesn't explode when handed large strings anymore
;; - Now much slower
;; 2006-10-02 / Matthew
;; - Cleaned up a little
;; - Despite comment above, it seems consistently faster
;; 2006-05-11 / Eli
;; - Cleaned up a lot, removed Larceny-isms
;; - Heavy optimization: not consing anything throughout the loop
;; 2007-09-17 / Eli
;; - making raw output possible
;; 2009-12-20 / Eli
;; - `mzscheme' -> `scheme/base'
;; - moved from mzlib/md5 to file/md5
;; - made it work on strings again

(require (for-syntax racket/base))

;;; Word arithmetic (32 bit)
;; Terminology
;;    word:  32 bit unsigned integer
;;    byte:   8 bit unsigned integer

;; Words are represented as a cons where the car holds the high 16 bits and the
;; cdr holds the low 16 bits.  Most good Scheme systems will have fixnums that
;; hold at least 16 bits as well as fast allocation, so this has a fair chance
;; at beating bignums for performance.

;; (word c) turns into a quoted pair '(hi . lo) if c is a literal number.  can
;; create a new word, compute one at compile-time etc
(define-syntax (word stx)
  (syntax-case stx ()
    ;; normal version (checks, allocates)
    [(word #:new c)
     #'(let ([n c])
         (if (<= 0 n 4294967296)
           (mcons (quotient n 65536) (remainder n 65536))
           (error 'word "out of range: ~e" n)))]
    ;; use when the number is known to be in range (allocates, no check)
    [(word #:new+safe c)
     #'(let ([n c]) (mcons (quotient n 65536) (remainder n 65536)))]
    ;; default form: compute at compile-time if possible
    [(word c)
     (let ([n (syntax-e #'c)])
       (if (integer? n)
         (if (<= 0 n 4294967295)
           (syntax-local-lift-expression
            #`(mcons #,(quotient n 65536) #,(remainder n 65536)))
           (raise-syntax-error #f "constant number out of range" stx))
         #'(word #:new c)))]))

;; destructive operations to save on consing

;; destructive cons
(define (cons! p x y)
  (set-mcar! p x)
  (set-mcdr! p y))

;; a := b
(define (word=! a b)
  (cons! a (mcar b) (mcdr b)))

;; a := a + b
(define (word+=! a b)
  (let ([t1 (+ (mcar a) (mcar b))]
        [t2 (+ (mcdr a) (mcdr b))])
    (cons! a
           (bitwise-and (+ t1 (arithmetic-shift t2 -16)) 65535)
           (bitwise-and t2 65535))))

(define word<<<!
  (let* ([masks '#(#x0 #x1 #x3 #x7 #xF #x1F #x3F #x7F #xFF #x1FF #x3FF #x7FF
                   #xFFF #x1FFF #x3FFF #x7FFF #xFFFF)])
    (lambda (a s)
      (let-values ([(hi lo s)
                    (cond [(< s 16) (values (mcar a) (mcdr a) s)]
                          [(< s 32) (values (mcdr a) (mcar a) (- s 16))]
                          [else (error 'word<<< "shift out of range: ~e" s)])])
        (cons!
         a
         (bitwise-ior
          (arithmetic-shift (bitwise-and hi (vector-ref masks (- 16 s))) s)
          (bitwise-and (arithmetic-shift lo (- s 16))
                       (vector-ref masks s)))
         (bitwise-ior
          (arithmetic-shift (bitwise-and lo (vector-ref masks (- 16 s))) s)
          (bitwise-and (arithmetic-shift hi (- s 16))
                       (vector-ref masks s))))))))

;; Bytes and words
;; The least significant byte of a word is the first

;; Converts a byte string to words, writes the result into `result'
;; bytes->word-vector! : vector byte-string -> void
(define (bytes->word-vector! result l-raw)
  ;; assumption: always getting a byte-string with 64 places
  ;; (unless (eq? 64 (bytes-length l-raw))
  ;;   (error 'bytes->word-vector! "something bad happened"))
  (let loop ([n 15])
    (when (<= 0 n)
      (let ([m (arithmetic-shift n 2)])
        (cons! (vector-ref result n)
               (+ (bytes-ref l-raw (+ 2 m))
                  (arithmetic-shift (bytes-ref l-raw (+ 3 m)) 8))
               (+ (bytes-ref l-raw m)
                  (arithmetic-shift (bytes-ref l-raw (+ 1 m)) 8))))
      (loop (sub1 n)))))

(define empty-port (open-input-bytes #""))

;; List Helper
;; read-block! : a-port done-n (vector word) -> (values vector a-port done-n)
;; reads 512 bytes from the port, writes them into the `result' vector of 16
;; 32-bit words when the port is exhausted it returns #f for the port and the
;; last few bytes padded
(define (read-block! a-port done result)
  (define-syntax write-words!
    (syntax-rules ()
      [(_ done buf) (bytes->word-vector! result (step2 (* 8 done) buf))]))
  (let ([l-raw (read-bytes 512/8 a-port)])
    (cond
      ;; File size was a multiple of 512 bits, or we're doing one more round to
      ;; add the correct padding from the short case
      [(eof-object? l-raw)
       (write-words! done
         (if (zero? (modulo done 512/8))
           ;; The file is a multiple of 512 or was 0, so there hasn't been a
           ;; chance to add the 1-bit pad, so we need to do a full pad
           (step1 #"")
           ;; We only enter this block when the previous block didn't have
           ;; enough room to fit the 64-bit file length, so we just add 448
           ;; bits of zeros and then the 64-bit file length (step2)
           (make-bytes 448/8 0)))
       (values #f done)]
      ;; We read exactly 512 bits, the algorithm proceeds as usual
      [(eq? (bytes-length l-raw) 512/8)
       (bytes->word-vector! result l-raw)
       (values a-port (+ done (bytes-length l-raw)))]
      ;; We read less than 512 bits, so the file has ended.
      [else
       (let ([done (+ done (bytes-length l-raw))])
         (write-words! done (step1 l-raw))
         (values
          (if (> (* 8 (bytes-length l-raw)) 446)
            ;; However, we don't have enough room to add the correct trailer,
            ;; so we add what we can, then go for one more round which will
            ;; automatically fall into the (eof-object? case)
            empty-port
            ;; Returning a longer vector than we should, luckily it doesn't
            ;; matter.  We read less than 512 bits and there is enough room for
            ;; the correct trailer.  Add trailer and bail
            #f)
          done))])))

;; MD5
;; The algorithm consists of four steps an encoding the result.  All we need to
;; do, is to call them in order.
;; md5 : string/bytes/port [bool] -> string
(define md5
  (case-lambda
    [(a-thing) (md5 a-thing #t)]
    [(a-thing hex-encode?)
     (let ([a-port
            (cond [(bytes? a-thing)  (open-input-bytes a-thing)]
                  [(string? a-thing) (open-input-string a-thing)]
                  [(input-port? a-thing) a-thing]
                  [else (raise-type-error 'md5 "input-port, bytes, or string"
                                          a-thing)])])
       (encode (step4 a-port) hex-encode?))]))

;; Step 1  -  Append Padding Bits
;; The message is padded so the length (in bits) becomes 448 modulo 512.  We
;; allways append a 1 bit and then append the proper numbber of 0's.  NB: 448
;; bits is 14 words and 512 bits is 16 words
;; step1 : bytes -> bytes
(define (step1 message)
  (let* ([nbytes (modulo (- 448/8 (bytes-length message)) 512/8)]
         [nbytes (if (zero? nbytes) 512/8 nbytes)])
    (bytes-append message
                  #"\x80" ; the 1 bit byte => one less 0 bytes to append
                  (make-bytes (sub1 nbytes) 0))))

;; Step 2  -  Append Length
;; A 64 bit representation of the bit length b of the message before the
;; padding of step 1 is appended.  Lower word first.
;; step2 : number bytes -> bytes
;;  org-len is the length of the original message in number of bits
(define (step2 len padded-message)
  (bytes-append padded-message (integer->integer-bytes len 8 #f #f)))

;; Step 3  -  Initialize MD Buffer
;; These magic constants are used to initialize the loop in step 4.
;;
;;          word A: 01 23 45 67
;;          word B: 89 ab cd ef
;;          word C: fe dc ba 98
;;          word D: 76 54 32 10

;; Step 4  -  Process Message in 16-Word Blocks
;; For each 16 word block, go through a round one to four.
;; step4 : input-port -> (list word word word word)

;; Step 3 :-) (magic constants)
(define (step4 a-port)
  ;; X is always a vector of 16 words (it changes in read-block!)
  (define X
    (vector
     (mcons 0 0) (mcons 0 0) (mcons 0 0) (mcons 0 0) (mcons 0 0) (mcons 0 0)
     (mcons 0 0) (mcons 0 0) (mcons 0 0) (mcons 0 0) (mcons 0 0) (mcons 0 0)
     (mcons 0 0) (mcons 0 0) (mcons 0 0) (mcons 0 0)))
  (define A (word #:new+safe #x67452301))
  (define B (word #:new+safe #xefcdab89))
  (define C (word #:new+safe #x98badcfe))
  (define D (word #:new+safe #x10325476))
  (define AA (mcons 0 0))
  (define BB (mcons 0 0))
  (define CC (mcons 0 0))
  (define DD (mcons 0 0))
  (define tmp (mcons 0 0))
  (let loop ([a-port a-port] [done 0])
    (if (not a-port)
      (list A B C D)
      (let-values ([(b-port done) (read-block! a-port done X)])
        (define-syntax step
          (syntax-rules ()
            [(_ a b c d e f g h)
             #| This is the `no GC version' (aka C-in-Scheme) of this:
             (set! a (word+ b (word<<< (word+ (word+ a (e b c d))
                                              (word+ (vector-ref X f)
                                                     (word h)))
                                       g)))
             |#
             (begin (e tmp b c d)
                    (word+=! a tmp)
                    (word+=! a (vector-ref X f))
                    (word+=! a (word h))
                    (word<<<! a g)
                    (word+=! a b))]))
        ;;---
        (word=! AA A) (word=! BB B) (word=! CC C) (word=! DD D)
        ;;---
        ;; the last column is generated with
        ;;  (lambda (i) (inexact->exact (floor (* 4294967296 (abs (sin i))))))
        ;; for i from 1 to 64
        (step A B C D F   0  7 3614090360)
        (step D A B C F   1 12 3905402710)
        (step C D A B F   2 17  606105819)
        (step B C D A F   3 22 3250441966)
        (step A B C D F   4  7 4118548399)
        (step D A B C F   5 12 1200080426)
        (step C D A B F   6 17 2821735955)
        (step B C D A F   7 22 4249261313)
        (step A B C D F   8  7 1770035416)
        (step D A B C F   9 12 2336552879)
        (step C D A B F  10 17 4294925233)
        (step B C D A F  11 22 2304563134)
        (step A B C D F  12  7 1804603682)
        (step D A B C F  13 12 4254626195)
        (step C D A B F  14 17 2792965006)
        (step B C D A F  15 22 1236535329)
        ;;---
        (step A B C D G   1  5 4129170786)
        (step D A B C G   6  9 3225465664)
        (step C D A B G  11 14  643717713)
        (step B C D A G   0 20 3921069994)
        (step A B C D G   5  5 3593408605)
        (step D A B C G  10  9   38016083)
        (step C D A B G  15 14 3634488961)
        (step B C D A G   4 20 3889429448)
        (step A B C D G   9  5  568446438)
        (step D A B C G  14  9 3275163606)
        (step C D A B G   3 14 4107603335)
        (step B C D A G   8 20 1163531501)
        (step A B C D G  13  5 2850285829)
        (step D A B C G   2  9 4243563512)
        (step C D A B G   7 14 1735328473)
        (step B C D A G  12 20 2368359562)
        ;;---
        (step A B C D H   5  4 4294588738)
        (step D A B C H   8 11 2272392833)
        (step C D A B H  11 16 1839030562)
        (step B C D A H  14 23 4259657740)
        (step A B C D H   1  4 2763975236)
        (step D A B C H   4 11 1272893353)
        (step C D A B H   7 16 4139469664)
        (step B C D A H  10 23 3200236656)
        (step A B C D H  13  4  681279174)
        (step D A B C H   0 11 3936430074)
        (step C D A B H   3 16 3572445317)
        (step B C D A H   6 23   76029189)
        (step A B C D H   9  4 3654602809)
        (step D A B C H  12 11 3873151461)
        (step C D A B H  15 16  530742520)
        (step B C D A H   2 23 3299628645)
        ;;---
        (step A B C D II  0  6 4096336452)
        (step D A B C II  7 10 1126891415)
        (step C D A B II 14 15 2878612391)
        (step B C D A II  5 21 4237533241)
        (step A B C D II 12  6 1700485571)
        (step D A B C II  3 10 2399980690)
        (step C D A B II 10 15 4293915773)
        (step B C D A II  1 21 2240044497)
        (step A B C D II  8  6 1873313359)
        (step D A B C II 15 10 4264355552)
        (step C D A B II  6 15 2734768916)
        (step B C D A II 13 21 1309151649)
        (step A B C D II  4  6 4149444226)
        (step D A B C II 11 10 3174756917)
        (step C D A B II  2 15  718787259)
        (step B C D A II  9 21 3951481745)
        ;;---
        (word+=! A AA) (word+=! B BB) (word+=! C CC) (word+=! D DD)
        ;;---
        (loop b-port done)))))

;; Each round consists of the application of the following basic functions.
;; They functions on a word bitwise, as follows.
;;          F(X,Y,Z) = XY v not(X) Z  (NB: or can be replaced with + in F)
;;          G(X,Y,Z) = XZ v Y not(Z)
;;          H(X,Y,Z) = X xor Y xor Z
;;          I(X,Y,Z) = Y xor (X v not(Z))

#| These functions used to be simple, for example:
     (define (F x y z)
       (word-or (word-and x y) (word-and (word-not x) z)))
   but we don't want to allocate stuff for each operation, so we add an output
   pair for each of these functions (the `t' argument).  However, this means
   that if we want to avoid consing, we need either a few such pre-allocated
   `register' values...  The solution is to use a macro that will perform an
   operation on the cars, cdrs, and set the result into the target pair.  Works
   only because these operations are symmetrical in their use of the two
   halves.
|#

(define-syntax cons-op!
  (syntax-rules ()
    [(cons-op! t (x ...) body)
     (cons! t (let ([x (mcar x)] ...) body) (let ([x (mcdr x)] ...) body))]))

(define (F t x y z)
  (cons-op! t (x y z)
    (bitwise-and (bitwise-ior (bitwise-and x y)
                              (bitwise-and (bitwise-not x) z))
                 65535)))

(define (G t x y z)
  (cons-op! t (x y z)
    (bitwise-and (bitwise-ior (bitwise-and x z)
                              (bitwise-and y (bitwise-not z)))
                 65535)))

(define (H t x y z)
  (cons-op! t (x y z) (bitwise-xor x y z)))

(define (II t x y z)
  (cons-op! t (x y z)
    (bitwise-and (bitwise-xor y (bitwise-ior x (bitwise-not z)))
                 65535)))

;; Step 5  -  Encoding
;; To finish up, we convert the word to hexadecimal string - and make sure they
;; end up in order.
;; encode : (list word word word word) bool -> byte-string

(define hex-digits #(48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102))
;; word->digits : word -> bytes-string,
;; returns a little endian result, but each byte is hi half and then lo half
(define (word->digits w)
  (let ([digit (lambda (n b)
                 (vector-ref hex-digits
                             (bitwise-and (arithmetic-shift n (- b)) 15)))]
        [lo (mcdr w)] [hi (mcar w)])
    (bytes (digit lo 4) (digit lo 0) (digit lo 12) (digit lo 8)
           (digit hi 4) (digit hi 0) (digit hi 12) (digit hi 8))))
(define (word->bytes w)
  (bytes-append (integer->integer-bytes (mcdr w) 2 #f #f)
                (integer->integer-bytes (mcar w) 2 #f #f)))
(define (encode l hex-encode?)
  (apply bytes-append (map (if hex-encode? word->digits word->bytes) l)))
