{- 
https://raw.githubusercontent.com/agda/agda/master/examples/Lookup.agda
 -}
module Lookup where

data Bool : Set where
  false : Bool
  true  : Bool

data IsTrue : Bool -> Set where
  isTrue : IsTrue true

data List (A : Set) : Set where
  []   : List A
  _::_ : A -> List A -> List A

data _×_ (A B : Set) : Set where
  _,_ : A -> B -> A × B

module Map {- comment -}
  (Key  : Set)
  (_==_ : Key -> Key -> Bool)
  (Code : Set)
  (Val  : Code -> Set) where

  infixr 40 _⟼_,_
  infix  20 _∈_

  data Map : List Code -> Set where
    ε     : Map []
    _⟼_,_ : forall {c cs} ->
            Key -> Val c -> Map cs -> Map (c :: cs)

  _∈_ : forall {cs} -> Key -> Map cs -> Bool
  k ∈ ε            = false
  k ∈ (k' ⟼ _ , m) with k == k'
  ...              | true  = true
  ...              | false = k ∈ m

  Lookup : forall {cs} -> (k : Key)(m : Map cs) -> IsTrue (k ∈ m) -> Set
  Lookup k ε ()
  Lookup k (_⟼_,_ {c} k' _ m) p with k == k'
  ... | true  = Val c
  ... | false = Lookup k m p

  lookup : {cs : List Code}(k : Key)(m : Map cs)(p : IsTrue (k ∈ m)) ->
           Lookup k m p
  lookup k ε ()
  lookup k (k' ⟼ v , m) p with k == k'
  ... | true  = v
  ... | false = lookup k m p
