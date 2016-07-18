#|
  https://raw.githubusercontent.com/rvirding/lfe/develop/examples/ping_pong.lfe
 |#
;; Copyright (c) Tim Dysinger tim <[<-on->]> dysinger.net

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.

(defmodule ping_pong
  (export (start_link 0) (ping 0))
  (export (init 1) (handle_call 3) (handle_cast 2)
          (handle_info 2) (terminate 2) (code_change 3))
  (behaviour gen_server))        ;Just indicates intent

(defun start_link ()
  (: gen_server start_link
    (tuple 'local 'ping_pong) 'ping_pong (list) (list)))

;; Client API

(defun ping ()
  (: gen_server call 'ping_pong 'ping))

;; Gen_server callbacks

(defrecord state (pings 0))

(defun init (args)
  (tuple 'ok (make-state pings 0)))

(defun handle_call (req from state)
  (let* ((new-count (+ (state-pings state) 1))
         (new-state (set-state-pings state new-count)))
    (tuple 'reply (tuple 'pong new-count) new-state)))

(defun handle_cast (msg state)
  (tuple 'noreply state))

(defun handle_info (info state)
  (tuple 'noreply state))

(defun terminate (reason state)
  'ok)

(defun code_change (old-vers state extra)
  (tuple 'ok state))
