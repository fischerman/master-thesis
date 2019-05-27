import mcl
import parlang
open mcl
open mcl.mclk

namespace assign_mcl

def sig : signature
| "tid" := { scope := scope.tlocal, type := ⟨_, [1], type.int⟩ }
| _ := { scope := scope.global, type := ⟨_, [100], type.int⟩ }


lemma a_is_global : is_global (sig "a") := by apply eq.refl
lemma tid_is_tlocal : is_tlocal (sig "tid") := by apply eq.refl

-- TODO generate those proofs directly from signature
-- make type classes out of those
-- make name explicit in state.update
def read_tid := (expression.tlocal_var "tid" (λ_, 0) (show type_of (sig "tid") = type.int, by apply eq.refl) (show (sig "tid").type.dim = 1, by apply eq.refl) tid_is_tlocal)

instance : has_one (expression sig (type_of (sig "b"))) := begin
    have : type_of (sig "b") = type.int := by apply eq.refl,
    rw this,
    apply_instance,
end

def p₁ : mclp sig := mclp.intro (λ m, 100) (
    mclk.global_assign "a" [read_tid] (by refl) (by refl) read_tid ;;
    mclk.global_assign "b" [read_tid] (by refl) (by refl) (read_tid + (expression.const_int 1 (by refl)))
)

def p₂ : mclp sig := mclp.intro (λ m, 100) (
    mclk.global_assign "b" [read_tid] (by refl) (by refl) (read_tid + (expression.const_int 1 (by refl))) ;;
    mclk.global_assign "a" [read_tid] (by refl) (by refl) read_tid
)

open parlang
open parlang.state
open parlang.thread_state

--#reduce update_global_vars_for_expr (read_tid + 1)

--set_option pp.implicit true

#print p₁._proof_1

lemma store_get_update (n) {idx : list ℕ} {sig : signature} {dim} {idx₁ : vector ℕ dim} {idx₂ : vector ℕ dim} {h : type_of (sig n) = signature.type_of n sig} {h' v} (hidx : idx₁.to_list = idx₂.to_list) : 
    @store _ _ (parlang_mcl_global sig) _ (λ (s : mcl.state sig), ⟨(n, idx), @state.get' sig (sig.type_of n) n dim idx₁ h h' (@state.update' sig (sig.type_of n) n dim idx₂ h h' v s)⟩) = 
    store (λ (s : mcl.state sig), ⟨(n, idx), v⟩) := begin
    sorry
end

lemma store_get_update' (n₁ n₂) {sig : signature} {dim₁ dim₂} {idx} {idx₁ : vector ℕ dim₁} {idx₂ : vector ℕ dim₂} {h₁ h₁' h₂ h₂' v} 
    (hn : n₁ = n₂) (hidx : idx₁.to_list = idx₂.to_list) (ht : type_map (sig.type_of n₁) = type_map (sig.type_of n₂)) : 
    @store _ _ (parlang_mcl_global sig) _ (λ (s : mcl.state sig), ⟨(n₁, idx), @state.get' sig (sig.type_of n₁) n₁ dim₁ idx₁  h₁ h₁' (@state.update' sig (sig.type_of n₂) n₂ dim₂ idx₂ h₂ h₂' v s)⟩) = 
    store (λ (s : mcl.state sig), ⟨(n₁, idx), (show (type_map $ sig.type_of n₁), begin rw ht, exact v end)⟩) := begin
end

--list.all (vector.to_list ?m_4) (bnot ∘ expr_reads ?m_5)

lemma vector_map_single {s : state sig} {t} {expr : expression sig t} : vector.map (eval s) [expr] = [eval s expr] := begin
    sorry
end

lemma lt_zero_one : 0 < 1 := by sorry

lemma store_access_elim {sig : signature} {n} {s : state n (state sig) (parlang_mcl_global sig)} {var} {expr : expression sig type.int} {val : lean_type_of (sig var)} {f} {t : fin n} {i} {ac₁ : vector bool n} 
(h₁ : i ∉ accesses (vector.nth ((map_active_threads ac₁ f s).threads) t)) 
(h₂ : i.1 ≠ var) :
i ∉ accesses (vector.nth ((map_active_threads ac₁ (f ∘ store (λ (s : state sig), ⟨(var, ([eval s expr] : vector _ _).val), val⟩)) s).threads) t) := begin
    sorry,
end

def store_expr {sig : signature} {t} (var : string) (idx : list (expression sig type.int)) (val : expression sig t) (h : type_of (sig var) = t) := 
@store _ _ (parlang_mcl_global sig) _ (λ (s : state sig), ⟨(var, idx.map (eval s)), begin unfold parlang_mcl_global, simp, dunfold signature.lean_type_of, dunfold lean_type_of, rw h, exact eval s val end⟩)

set_option trace.simplify.rewrite true 

-- this approach is like computing both programs and comparing their output
-- this is a fairly naive approach, another approach would be to show that their behavior is equal (based on the fact that we have to show equality)
example : mclp_rel eq p₁ p₂ eq := begin
    apply rel_mclk_to_mclp,

    apply mcl.skip_right.mpr,
    apply mcl.seq,
    swap,

    apply mcl.skip_left_after.mpr,
    apply mcl.skip_right.mpr,
    apply mcl.seq,
    tactic.swap,

    -- break it down into individual proofs
    apply add_skip_left.mpr,
    apply mcl.seq,
    tactic.swap,
    {
        apply mcl.global_assign_right,
    },{
        apply mcl.global_assign_right,
    }, {
        apply mcl.global_assign_left,
    },
    apply mcl.global_assign_left',
    intros _ _ _ _ _ _ h,
    cases h with m₁ h,
    cases h with m₂ h,
    simp,
    have : n₁ = n₂ := begin
        sorry
    end,
    subst this,
    have hseq : s₁ = s₂ := begin
        sorry
    end,

    -- the proof obligation in the form of a map thread on syncable is the simple version because we never consider threads to change active state (here all threads are always active)

    -- h expresses the initial state (we might want to compress this information)
    -- todo: we need ways to reason about ranges of memory (dependent on tid, ergo n₁)
    -- e.g. using foldr
    apply exists.intro ((list.range n₁).foldl (λ (m : parlang.memory (parlang_mcl_global sig)) i, ((memory.update ("b", [i]) (i + 1 : ℕ) ∘ (memory.update ("a", [i]) i))) m) m₁),
    
    split, {
        have : update_global_vars_for_expr read_tid = id := by refl,
        rw this,
        have : update_global_vars_for_expr (read_tid + (expression.const_int 1 (show type_of (sig "b") = type_of (sig "b"), by refl))) = id := by refl,
        rw this,
        simp,

        -- put maps in store
        -- todo we could distinct cases
           -- store stores the same value as update
           -- update changes the value of an index of store
           -- update can be ignored
        rw ← function.comp.assoc,
        rw ← function.comp.assoc,
        rw thread_state_map,
        rw ← function.comp.assoc,
        rw thread_state_map',
        rw function.comp.assoc,
        rw function.comp.assoc,
        rw syncable_remove_map,
        
        rw ← function.comp.assoc,
        rw thread_state_map',
        rw function.comp.assoc,
        rw syncable_remove_map,

        have hbni : list.all (vector.to_list [read_tid]) (bnot ∘ expr_reads "b") = tt := by refl,
        have hani : list.all (vector.to_list [read_tid]) (bnot ∘ expr_reads "a") = tt := by refl,
        have hani' : expr_reads "a" read_tid = ff := by refl,
        have hbni' : expr_reads "b" read_tid = ff := by refl,
        have hbni'' : expr_reads "b" (read_tid + expression.const_int 1 p₁._proof_5) = ff := by refl,
        have hani'' : expr_reads "a" (read_tid + expression.const_int 1 p₁._proof_5) = ff := by refl,

        -- resolve get and update (the result should only be mcl_init, literals and memory (in case of loads))
        
        simp [state_get_update_success _ _ _ _ _, eval_update_ignore' hbni, eval_update_ignore' hani, eval_update_ignore hani'', eval_update_ignore hbni''],
        conv {
            congr,
            congr,
            skip,
            congr,
            congr,
            funext,
            rw vector_map_single,
            rw vector.to_list,
            rw eval_update_ignore hbni',
            rw eval_update_ignore hani',
            skip,
            congr,
            funext,
            rw vector_map_single,
            rw vector.to_list,
            rw eval_update_ignore hani',
        },
        intro,
        by_cases ha : i.1 = "a" ∧ i.2.length = 1,
        -- only stores left
        -- find a way to resolve the stores all together
        {
            right,
            use (i.2.nth_le 0 begin
                rw ha.right,
                apply lt_zero_one,
            end),
            apply exists.intro,
            split,
            {
                sorry, -- find the correct store instruction which performs the write
            }, {
                split,
                {
                    sorry, -- proof that the value is the same
                }, {
                    intros t' ht'n hneqtt',
                    apply store_access_elim,
                }
            }
        }
    }

end

end assign_mcl