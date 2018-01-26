-- https://github.com/leanprover/lean/raw/master/library/data/dlist.lean
/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Leonardo de Moura
-/
universes u
/--
A difference list is a function that, given a list, returns the original
contents of the difference list prepended to the given list.

This structure supports `O(1)` `append` and `concat` operations on lists, making it
useful for append-heavy uses such as logging and pretty printing.
-/
structure dlist (α : Type u) :=
(apply     : list α → list α)
(invariant : ∀ l, apply l = apply [] ++ l)

namespace dlist
open function
variables {α : Type u}

local notation `♯`:max := by abstract {intros, rsimp}

/-- Convert a list to a dlist -/
def of_list (l : list α) : dlist α :=
⟨append l, ♯⟩

/-- Convert a lazily-evaluated list to a dlist -/
def lazy_of_list (l : thunk (list α)) : dlist α :=
⟨λ xs, l () ++ xs, ♯⟩

/-- Convert a dlist to a list -/
def to_list : dlist α → list α
| ⟨xs, _⟩ := xs []

/--  Create a dlist containing no elements -/
def empty : dlist α :=
⟨id, ♯⟩

local notation a `::_`:max := list.cons a

/-- Create dlist with a single element -/
def singleton (x : α) : dlist α :=
⟨x::_, ♯⟩

local attribute [simp] function.comp

/-- `O(1)` Prepend a single element to a dlist -/
def cons (x : α) : dlist α →  dlist α
| ⟨xs, h⟩ := ⟨x::_ ∘ xs, ♯⟩

/-- `O(1)` Append a single element to a dlist -/
def concat (x : α) : dlist α → dlist α
| ⟨xs, h⟩ := ⟨xs ∘ x::_, ♯⟩

/-- `O(1)` Append dlists -/
protected def append : dlist α → dlist α → dlist α
| ⟨xs, h₁⟩ ⟨ys, h₂⟩ := ⟨xs ∘ ys, ♯⟩

instance : has_append (dlist α) :=
⟨dlist.append⟩

local attribute [simp] of_list to_list empty singleton cons concat dlist.append

lemma to_list_of_list (l : list α) : to_list (of_list l) = l :=
by cases l; simp

lemma of_list_to_list (l : dlist α) : of_list (to_list l) = l :=
begin
   cases l with xs,
   have h : append (xs []) = xs,
   { intros, funext x, simp [l_invariant x] },
   simp [h]
end

lemma to_list_empty : to_list (@empty α) = [] :=
by simp

lemma to_list_singleton (x : α) : to_list (singleton x) = [x] :=
by simp

lemma to_list_append (l₁ l₂ : dlist α) : to_list (l₁ ++ l₂) = to_list l₁ ++ to_list l₂ :=
show to_list (dlist.append l₁ l₂) = to_list l₁ ++ to_list l₂, from
by cases l₁; cases l₂; simp; rsimp

lemma to_list_cons (x : α) (l : dlist α) : to_list (cons x l) = x :: to_list l :=
by cases l; rsimp

lemma to_list_concat (x : α) (l : dlist α) : to_list (concat x l) = to_list l ++ [x] :=
by cases l; simp; rsimp

section transfer

protected def rel_dlist_list (d : dlist α) (l : list α) : Prop :=
to_list d = l

instance bi_total_rel_dlist_list : @relator.bi_total (dlist α) (list α) dlist.rel_dlist_list :=
⟨assume d, ⟨to_list d, rfl⟩, assume l, ⟨of_list l, to_list_of_list l⟩⟩

protected lemma rel_eq :
  (dlist.rel_dlist_list ⇒ dlist.rel_dlist_list ⇒ iff) (@eq (dlist α)) eq
| l₁ ._ rfl l₂ ._ rfl := ⟨congr_arg to_list,
  assume : to_list l₁ = to_list l₂,
  have of_list (to_list l₁) = of_list (to_list l₂), from congr_arg of_list this,
  by simp [of_list_to_list] at this; assumption⟩

protected lemma rel_empty : dlist.rel_dlist_list (@empty α) [] :=
to_list_empty

protected lemma rel_singleton : (@eq α ⇒ dlist.rel_dlist_list) (λx, singleton x) (λx, [x])
| ._ x rfl := to_list_singleton x

protected lemma rel_append :
  (dlist.rel_dlist_list ⇒ dlist.rel_dlist_list ⇒ dlist.rel_dlist_list) (λ(x y : dlist α), x ++ y) (λx y, x ++ y)
| l₁ ._ rfl l₂ ._ rfl := to_list_append l₁ l₂

protected lemma rel_cons :
  (@eq α ⇒ dlist.rel_dlist_list ⇒ dlist.rel_dlist_list) cons (λx y, x :: y)
| x ._ rfl l ._ rfl := to_list_cons x l

protected lemma rel_concat :
  (@eq α ⇒ dlist.rel_dlist_list ⇒ dlist.rel_dlist_list) concat (λx y, y ++ [x])
| x ._ rfl l ._ rfl := to_list_concat x l

protected meta def transfer : tactic unit := do
  _root_.transfer.transfer [`relator.rel_forall_of_total, `dlist.rel_eq, `dlist.rel_empty,
    `dlist.rel_singleton, `dlist.rel_append, `dlist.rel_cons, `dlist.rel_concat]

example : ∀(a b c : dlist α), a ++ (b ++ c) = (a ++ b) ++ c :=
begin
  dlist.transfer,
  intros,
  simp
end

example : ∀(a : α), singleton a ++ empty = singleton a :=
begin
  dlist.transfer,
  intros,
  simp
end

end transfer

end dlist
