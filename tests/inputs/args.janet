# https://github.com/MorganPeterson/args/blob/main/args.janet

# https://github.com/AlDanial/cloc/issues/802
(defn- to-byte
  "convert chars to byte and only return first result"
  [x]
  (get (string/bytes x) 0))

(defn- parse
  "parse command line arguments"
  [args]
  (def f
    (fiber/new 
      (fn []
        (loop [x :in args]
          (yield x)))))
  (def dash (to-byte "-"))
  (def spce (to-byte " "))

  (var results @[])
  (var kpwh false) # keep flag whole if no dash
  
  (while (fiber/can-resume? f)
    (var args0 (resume f))

    (cond
      (= args0 dash) (set args0 (resume f))
      (set kpwh true))
    
    (if (and (= args0 dash) (not (fiber/can-resume? f))) (break))
    
    (cond
      (= args0 dash)
      (do
        (var a @[])
        (loop [x :in f :until (or (= x spce) (not (fiber/can-resume? f)))]
          (array/push a (string/from-bytes x)))
        (array/push results (string/join a)))
      (do
        (var b @[])
        (when (not (nil? args0))
          (array/push b (string/from-bytes args0))
          (loop [x :in f :until (or (= x spce) (not (fiber/can-resume? f)))]
            (array/push b (string/from-bytes x)))
          (cond
            (true? kpwh) (array/push results (string/join b))
            (do
              (array/concat results b)
              (set kpwh false)))))))
  results)

(defn flags
  "take in raw commandline string"
  [args]
  (parse (string/join (tuple/slice args 1) " ")))
