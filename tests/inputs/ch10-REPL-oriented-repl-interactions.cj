; https://github.com/clojurebook/ClojureProgramming/blob/master/ch10-REPL-oriented-repl-interactions.clj
; then renamed to ch10-REPL-oriented-repl-interactions.cj to test disambiguation with Cangjie

;-----
(ns com.clojurebook.fn-browser
  (:import (javax.swing JList JFrame JScrollPane JButton)
           java.util.Vector))

(defonce fn-names (->> (ns-publics 'clojure.core)
                    (map key)
                    sort
                    Vector.
                    JList.))

(defn show-info [] )

(defonce window (doto (JFrame. "\"Interactive Development!\"") 
                  (.setSize (java.awt.Dimension. 400 300))
                  (.add (JScrollPane. fn-names))
                  (.add java.awt.BorderLayout/SOUTH
                    (doto (JButton. "Show Info")
                      (.addActionListener (reify java.awt.event.ActionListener
                                            (actionPerformed [_ e] (show-info))))))
                  (.setVisible true)))


;-----
(in-ns 'com.clojurebook.fn-browser)

(import '(javax.swing JOptionPane JTextArea))

(defn show-info
  []
  (when-let [selected-fn (.getSelectedValue fn-names)]
    (JOptionPane/showMessageDialog
      window
      (-> (ns-resolve 'clojure.core selected-fn)
        meta
        :doc
        (JTextArea. 10 40)
        JScrollPane.)
      (str "Doc string for clojure.core/" selected-fn)
      JOptionPane/INFORMATION_MESSAGE)))


;-----
(split-with keyword? [:a :b :c 1 2 3])
;= [(:a :b :c) (1 2 3)]
(zipmap (first *1) (second *1))
;= {:c 3, :b 2, :a 1}
(apply zipmap (split-with keyword? [:a :b :c 1 2 3]))
;= {:c 3, :b 2, :a 1}


;-----
(throw (Exception. "foo"))
;= Exception foo  user/eval1 (NO_SOURCE_FILE:1)
(pst)
; Exception foo
;   user/eval1 (NO_SOURCE_FILE:1)
;   clojure.lang.Compiler.eval (Compiler.java:6465)
; ...


;-----
(apropos #"^ref")
;= (ref-max-history refer-clojure ref-set ref-history-count ref ref-min-history refer)


;-----
(source merge)
; (defn merge
;   "Returns a map that consists of the rest of the maps conj-ed onto
;   the first.  If a key occurs in more than one map, the mapping from
;   the latter (left-to-right) will be the mapping in the result."
;   {:added "1.0"
;    :static true}
;   [& maps]
;   (when (some identity maps)
;     (reduce1 #(conj (or %1 {}) %2) maps)))


;-----
(require 'clojure.string)
;= nil
(dir clojure.string)
; blank?
; capitalize
; escape
; join
; lower-case
; replace
; replace-first
; reverse
; split
; split-lines
; trim
; trim-newline
; triml
; trimr
; upper-case


;-----
(ns clean-namespace)
;= nil
(ns-aliases *ns*)
;= {}
(require '[clojure.set :as set])
;= nil
(ns-aliases *ns*)
;= {set #<Namespace clojure.set>}
(ns-publics *ns*)
;= {}
(def x 0)
;= #'clean-namespace/x
(ns-publics *ns*)
;= {x #'clean-namespace/x}


;-----
(ns-unalias *ns* 'set)
;= nil
(ns-aliases *ns*)
;= {}
(ns-unmap *ns* 'x)
;= nil
(ns-publics *ns*)
;= {}


;-----
(in-ns 'user)
;= #<Namespace user>
(filter #(= 'clean-namespace (ns-name %)) (all-ns))
;= (#<Namespace clean-namespace>)
(remove-ns 'clean-namespace)
;= #<Namespace clean-namespace>
(filter #(= 'clean-namespace (ns-name %)) (all-ns))
;= ()


;-----
(setq inferior-lisp-program "lein repl")


;-----
lein plugin install swank-clojure 1.3.4


;-----
[swank-clojure "1.3.4"]


;-----
(defn debug-me
  [x y]
  (let [z (merge x y)]
    (swank.core/break)))


;-----
(let [log-capacity 5000
      events (agent [])]
  (defn log-event [e]
    (send events #(if (== log-capacity (count %))   
                    (-> % (conj e) (subvec 1))
                    (conj % e)))
    e)
  (defn events [] @events))


;-----
(doseq [request (repeatedly 10000 (partial rand-nth [{:referrer "twitter.com"}
                                                     {:referrer "facebook.com"}
                                                     {:referrer "twitter.com"}
                                                     {:referrer "reddit.com"}]))]
  (log-event request))
;= nil
(count (events))
;= 5000


;-----
(frequencies (events))
;= {{:referrer "twitter.com"} 2502,
    {:referrer "facebook.com"} 1280,
    {:referrer "reddit.com"} 1218}


;-----
(defn a [b] (+ 5 b))
;= #'user/a
(def b (partial a 5))
;= #'user/b
(b)
;= 10
(defn a [b] (+ 10 b))
;= #'user/a
(b)
;= 10


;-----
(def b (partial #'a 5))
;= #'user/b
(b)
;= 15
(defn a [b] (+ 5 b))
;= #'user/a
(b)
;= 10


