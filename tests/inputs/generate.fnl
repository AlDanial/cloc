; https://github.com/bakpakin/Fennel/raw/master/generate.fnl

;; A general-purpose function for generating random values.

(var generate nil)

(local random-char
       (fn []
         (if (> (math.random) 0.9)
             (string.char (+ 48 (math.random 10)))
             (> (math.random) 0.5)        ; an in-line comment
             (string.char (+ 97 (math.random 26)))
             (> (math.random) 0.5)
             (string.char (+ 65 (math.random 26)))
             (> (math.random) 0.5)
             (string.char (+ 32 (math.random 11)))
             (> (math.random) 0.5)
             (string.char (+ 45 (math.random 2)))
             :else
             (string.char (+ 58 (math.random 5))))))

(local generators {:number (fn [] ; weighted towards mid-range integers
                             (if (> (math.random) 0.9)
                                 (let [x (math.random 2147483647)]
                                   (math.floor (- x (/ x 2))))
                                 (> (math.random) 0.2)
                                 (math.floor (math.random 2048))
                                 :else (math.random)))
                   :string (fn []
                             (var s "")
                             (for [_ 1 (math.random 16)]
                               (set s (.. s (random-char))))
                             s)
                   :table (fn [table-chance]
                            (let [t {}]
                              (var k nil)
                              (for [_ 1 (math.random 16)]
                                ;; no nans plz
                                (set k (generate 0.9))
                                (while (~= k k) (set k (generate 0.9)))
                                (tset t k (generate (* table-chance 1.5))))
                              t))
                   :boolean (fn [] (> (math.random) 0.5))})

(set generate
     (fn [table-chance]
       (local table-chance (or table-chance 0.5))
       (if (> (math.random) 0.5) (generators.number)
           (> (math.random) 0.5) (generators.string)
           (> (math.random) table-chance) (generators.table table-chance)
           :else (generators.boolean))))

generate
