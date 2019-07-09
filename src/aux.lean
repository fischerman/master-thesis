import data.list.basic
import data.vector

universes u v w
variables {n : ℕ} {α β γ : Type}

namespace list

lemma list_length_neq_zero {α} : ∀{l : list α}, l.length ≠ 0 → ∃ x xs, l = (x :: xs)
| []     h := (h rfl).elim
| (a::l) h := ⟨_, _, rfl⟩

lemma list_length_tail {α β : Type} {x : α} {y : β} {xs ys : list _}
  (h : (x :: xs).length = (y :: ys).length) : xs.length = ys.length :=
by simpa using h 

def range_fin_core (dim : ℕ) : Π n : ℕ, n <= dim → list (fin dim) → list (fin dim)
| 0 h l := l
| (nat.succ n) hs l := have h : n < dim := begin apply nat.succ_le_succ_iff.mp, apply nat.lt_succ_iff.mpr hs, end, range_fin_core n (le_of_lt h) (⟨n, h⟩ :: l)

def range_fin (n : ℕ) : list (fin n) :=
range_fin_core n n (by refl) []

@[simp] lemma length_range_nth : length (range_fin n) = n := begin
  admit
end

end list

namespace nat

lemma lt_neq_zeor (n m : ℕ) : n < m → m ≠ 0 := begin
    intro,
    intro b,
    rw b at a,
    cases a,
end

end nat

namespace set

lemma union_no_mem_left {α : Type} {a : α} {b c : set α} (h : a ∉ b ∪ c) : a ∉ b := sorry

end set

namespace vector

protected def mem {α : Type u} {n : ℕ} : α → vector α n → Prop
| a v := a ∈ v.to_list

instance {α : Type u} {n : ℕ} : has_mem α (vector α n) :=
⟨vector.mem⟩

lemma mem_def {α : Type*} {n : ℕ} (a : α) (v : vector α n) : a ∈ v ↔ a ∈ v.to_list :=
iff.rfl

lemma mem_nil {α : Type u} {a : α} : a ∉ (@vector.nil α) := by sorry

lemma nat_le_zero {n : ℕ} : n < 0 → false := by sorry

#check vector.cons

lemma mem_elim_head {α : Type u} {n} {tl : vector α n} {a hd : α} :
  a ∈ tl → a ∈ cons hd tl :=
sorry

lemma contains_nth {α : Type} : ∀{n : ℕ} {v : vector α n} {i : fin n}, (v.nth i) ∈ v
| n ⟨l, rfl⟩ ⟨i, hi⟩ :=
  begin
    dsimp only [vector.nth, vector.has_mem, vector.mem, to_list],
    rw list.mem_iff_nth_le,
    exact ⟨i, hi, rfl⟩
  end

lemma eq_element_wise {α : Type} : ∀{a b : vector α n}, (∀ i, a.nth i = b.nth i) → a = b := begin
  -- TODO needs fixing
  intros a b hieq,
  apply vector.eq,
  cases a,
  cases b,
  repeat { rw to_list },
  simp,
  induction a_val generalizing b_val,
  case list.nil {
    cases b_val,
    { refl },
    {
      rw list.length at a_property b_property,
      rw ← b_property at a_property,
      contradiction,
    }
  },
  case list.cons {
    cases b_val,
    {
      rw list.length at a_property b_property,
      rw ← b_property at a_property,
      contradiction,
    },
    {
      sorry
    }
  }
end
-- | ⟨[], _⟩ ⟨[], ha⟩ _ _ := by refl
-- | ⟨ a :: as , _⟩ ⟨ b :: bs, _⟩ i hieq := begin
  
-- end


--   intros i hieq,
--   exact match a with
--   | ⟨[], ha⟩ := 
--     begin
--       exact match b with
--       | ⟨[], ha⟩ := sorry
--       |
--       end,
--     end
--   end
-- end

@[simp] lemma vector_0_eq {α : Type} : ∀(v : vector α 0), v = vector.nil
| ⟨l, hl⟩ := subtype.eq $ show l = list.nil, from list.length_eq_zero.1 hl

lemma vector_0_eq' {α : Type} {v v' : vector α 0} : v = v' := sorry

@[simp] lemma map₂_nil {α β γ : Type} {f : α → β → γ} :
  ∀ (v : vector α 0) w, vector.map₂ f v w = vector.nil
| ⟨[], _⟩ ⟨[], _⟩ := by simp [vector.map₂, vector.nil]

@[simp] lemma map₂_nil' {α β γ : Type} {f : α → β → γ} (v : vector α 0) (p) :
  vector.map₂ f v ⟨list.nil, p⟩ = vector.nil := sorry

@[simp] lemma nth_map (f : α -> β) (v : vector α n) (i) : (v.map f).nth i = f (v.nth i) := sorry

@[simp] lemma nth_map₂ (f : α → β → γ) (v : vector α n) (w : vector β n) (i) : nth (map₂ f v w) i = f (v.nth i) (w.nth i) := sorry

-- example {f a as b bs h h' h''} :
--   vector.map₂ f ⟨ a :: as, h⟩ ⟨b :: bs, h'⟩ = ⟨f a b :: vector.map₂ f as bs, h''⟩ :=
-- sorry

def range (n : ℕ) : vector ℕ n := ⟨list.range n, sorry⟩

lemma range_nth {n : ℕ} {i : fin n} : (range n).nth i = i := sorry

def range_fin (n : ℕ) : vector (fin n) n := ⟨list.range_fin n, sorry⟩

@[simp] lemma length_map {α n} (f : α → β) (l : vector α n) : length (map f l) = length l := sorry

@[simp] lemma length_range_nth : length (range_fin n) = n := sorry

lemma eq_one {α : Type} (v : vector α 1) (v' : vector α 1) (h : v.nth ⟨0, sorry⟩ = v'.nth ⟨0, by sorry⟩) : v = v' := sorry

lemma length_list {α : Type} {n} {v : vector α n} : list.length (vector.to_list (v)) = vector.length v := begin
  admit,
end

end vector

namespace bool

lemma eq_tt_coe {b : bool} : b ↔ (b = tt) := begin
  sorry,
end

lemma bnot_bnot {α : Type} {f : α → bool} : (bnot ∘ bnot ∘ f) = f := begin
  sorry,
end

end bool