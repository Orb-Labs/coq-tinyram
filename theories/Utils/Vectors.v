From Coq Require Import
  Lia.
From TinyRAM.Utils Require Import
  Fin.
From TinyRAM.Utils Require Import
  Arith.
Import PeanoNat.Nat.
Require Import ProofIrrelevance.
Require Import VectorDef.
Import VectorNotations.
Import EqNotations.

Definition vector_length_coerce : forall {A n m},
    n = m ->
    Vector.t A n ->
    Vector.t A m.
  intros A n m eq v. rewrite <- eq. assumption. Defined.

Theorem vector_length_coerce_trans : forall {A n m o}
    (eq1 : n = m) (eq2 : m = o) (v : Vector.t A n),
    (vector_length_coerce eq2 (vector_length_coerce eq1 v))
    = (vector_length_coerce (eq_trans eq1 eq2) v).
Proof.
  intros A n m o eq1 eq2 v.
  destruct eq1, eq2.
  reflexivity.
Qed.

Theorem vector_length_coerce_id : forall {A n}
    (eq : n = n) (v : Vector.t A n),
    (vector_length_coerce eq v)
    = v.
Proof.
  intros A n eq v.
  replace eq with (eq_refl n).
  - reflexivity.
  - apply proof_irrelevance.
Qed.

Theorem vector_length_coerce_inv : forall {A n m}
    (eq : n = m) (v : Vector.t A n),
    (vector_length_coerce (eq_sym eq) (vector_length_coerce eq v)) = v.
Proof.
  intros A n m eq v.
  destruct eq.
  reflexivity.
Qed.

Theorem vector_length_coerce_inv2 : forall {A n m}
  (eq : m = n) (v : Vector.t A n),
  (vector_length_coerce eq (vector_length_coerce (eq_sym eq) v)) = v.
Proof.
  intros A n m eq v.
  destruct eq.
  reflexivity.
Qed.

Theorem vector_length_coerce_cons : forall {A n m}
  (h : A) (vn : Vector.t A n) (eq : S n = S m),
  vector_length_coerce eq (h :: vn)
  = h :: vector_length_coerce (succ_inj _ _ eq) vn.
Proof.
  intros A n m h vn eq.
  destruct (succ_inj n m eq).
  replace eq with (eq_refl (S n)).
  2: { apply proof_irrelevance. }
  simpl; f_equal.
Qed.

Theorem vector_length_coerce_app_l : forall {A n m o}
  (vn : Vector.t A n) (vm : Vector.t A m) (eq : n + m = n + o),
  vector_length_coerce eq (vn ++ vm)
  = vn ++ vector_length_coerce (Plus.plus_reg_l _ _ _ eq) vm.
Proof.
  intros A n m o vn vm eq.
  destruct (Plus.plus_reg_l _ _ _ eq).
  replace eq with (eq_refl (n + m)).
  2: { apply proof_irrelevance. }
  simpl; f_equal.
Qed.

Theorem vector_length_coerce_app_r : forall {A n m o}
  (vn : Vector.t A n) (vm : Vector.t A m) (eq : n + m = o + m),
  vector_length_coerce eq (vn ++ vm)
  = vector_length_coerce (plus_reg_r _ _ _ eq) vn ++ vm.
Proof.
  intros A n m o vn vm eq.
  destruct (plus_reg_r _ _ _ eq).
  replace eq with (eq_refl (n + m)).
  2: { apply proof_irrelevance. }
  simpl; f_equal.
Qed.

Theorem vector_length_coerce_app_funct : forall {A n1 n2 m1 m2}
  (neq : n1 = n2) (meq : m1 = m2)
  (vn : Vector.t A n1) (vm : Vector.t A m1),
  vector_length_coerce neq vn ++ vector_length_coerce meq vm
  = vector_length_coerce (f_equal2_plus _ _ _ _ neq meq) (vn ++ vm).
Proof.
  intros A n1 n2 m1 m2 neq meq vn vm.
  destruct neq, meq.
  replace (f_equal2_plus _ _ _ _ _ _) with (eq_refl (n1 + m1)).
  { reflexivity. }
  apply proof_irrelevance.
Qed.

Theorem vector_length_coerce_app_assoc_1 : forall {A n m o}
  (vn : Vector.t A n) (vm : Vector.t A m) (vo : Vector.t A o),
  vector_length_coerce (add_assoc n m o) (vn ++ (vm ++ vo))
  = (vn ++ vm) ++ vo.
Proof.
  intros A n m o vn vm vo.
  induction vn.
  - simpl.
    replace (add_assoc 0 m o) with (eq_refl (m + o)).
    + reflexivity.
    + apply proof_irrelevance.
  - simpl.
    rewrite vector_length_coerce_cons.
    f_equal.
    rewrite <- IHvn.
    f_equal.
    apply proof_irrelevance.
Qed.

Theorem vector_length_coerce_app_assoc_2 : forall {A n m o}
  (vn : Vector.t A n) (vm : Vector.t A m) (vo : Vector.t A o),
  vector_length_coerce (eq_sym (add_assoc n m o)) ((vn ++ vm) ++ vo)
  = vn ++ (vm ++ vo).
Proof.
  intros A n m o vn vm vo.
  induction vn.
  - simpl.
    replace (add_assoc 0 m o) with (eq_refl (m + o)).
    + reflexivity.
    + apply proof_irrelevance.
  - simpl.
    rewrite vector_length_coerce_cons.
    f_equal.
    rewrite <- IHvn.
    f_equal.
    apply proof_irrelevance.
Qed.

Theorem vector_nil_eq : forall {A} (v : t A 0),
  v = [].
Proof.
  intros A v.
  apply (case0 (fun vnil => vnil = [])).
  reflexivity.
Qed.

Definition vector_cons_split : forall {A n}
  (v : Vector.t A (S n)), 
  { x : A & { vtl : Vector.t A n | v = Vector.cons A x n vtl } }.
  intros A n v.
  exists (Vector.hd v), (Vector.tl v). apply Vector.eta.
Defined.


Definition replace :
  forall {A n} (v : Vector.t A n) (p: fin n) (a : A), Vector.t A n.
  intros A n; induction n as [|n IHn]; intros v [p pprp] a.
  - apply Vector.nil.
  - destruct (vector_cons_split v) as [vhd [vtl _]].
    destruct p.
    + apply Vector.cons.
      * exact a.
      * exact vtl.
    + apply Vector.cons.
      * exact vhd.
      * apply (fun x => IHn vtl x a).
        exists p.
        lia.
Defined. 

Definition nth :
  forall {A n} (v : Vector.t A n) (p: fin n), A.
  intros A n; induction n as [|n IHn]; intros v [p pprp].
  - destruct (nlt_0_r _ pprp).
  - destruct (vector_cons_split v) as [vhd [vtl _]].
    destruct p.
    + exact vhd.
    + apply (IHn vtl).
      exists p.
      lia.
Defined.

Theorem vector_rev_append_nil_o : forall {A n}
  (v : Vector.t A n),
  rev_append [] v = v.
Proof.
  intros A n v.
  destruct v.
  - unfold rev_append.
    simpl.
    replace (Plus.plus_tail_plus 0 0) with (eq_refl 0).
    { reflexivity. } { apply proof_irrelevance. }
  - unfold rev_append.
    simpl rev_append_tail.
    replace (Plus.plus_tail_plus 0 (S n))
       with (eq_refl (S n)).
    { reflexivity. } { apply proof_irrelevance. }
Qed.

Theorem rev_coerce_unfold : forall {A n}
  (v : Vector.t A n),
  rev v = 
  vector_length_coerce (eq_sym (plus_n_O n))
    (rev_append v []).
Proof.
  reflexivity.
Qed.

Theorem vector_rev_nil_nil : forall {A},
  rev [] = ([] : Vector.t A 0).
Proof.
  intros A.
  rewrite rev_coerce_unfold.
  rewrite vector_rev_append_nil_o.
  replace (plus_n_O 0) with (eq_refl 0).
  { reflexivity. } { apply proof_irrelevance. }
Qed.

Theorem vector_rev_sing_sing : forall {A} (h : A),
  rev [h] = [h].
Proof.
  intros A h.
  rewrite rev_coerce_unfold.
  replace (rev_append [h] []) with [h].
  { replace (plus_n_O 1) with (eq_refl 1).
    { reflexivity. } { apply proof_irrelevance. } }
  unfold rev_append.
  simpl. 
  replace (Plus.plus_tail_plus 1 0) with (eq_refl 1).
  { reflexivity. } { apply proof_irrelevance. }
Qed.

Definition last_ : forall {A n}, t A (n + 1) -> A.
  intros A n v.
  rewrite add_comm in v.
  apply (@last A n).
  exact v.
Defined.

Definition most : forall {A n}, t A (S n) -> t A n.
  intros A n v.
  induction n.
  - apply Vector.nil.
  - apply Vector.cons.
    + exact (hd v).
    + apply IHn.
      exact (tl v).
Defined.

Definition most_ : forall {A n}, t A (n + 1) -> t A n.
  intros A n v.
  rewrite add_comm in v.
  apply (@most A n).
  exact v.
Defined.

  
Theorem vector_snoc_eta : forall {A n}
  (v : Vector.t A (n + 1)),
  v = most_ v ++ [last_ v].
Proof.
  intros A n v.
  induction n.
  - rewrite (vector_nil_eq (most_ v)).
    rewrite (Vector.eta v).
    rewrite (vector_nil_eq (tl v)).
    simpl; f_equal.
    unfold last_.
    replace (add_comm 0 1) with (eq_refl 1).
    2: { apply proof_irrelevance. }
    reflexivity.
  - rewrite (Vector.eta v).
    assert (tl v = most_ (tl v) ++ [last_ (tl v)]).
    { apply IHn. }
    rewrite H at 1.
    simpl; f_equal.
    + change (eq_rect _ _ _ _ _)
        with (vector_length_coerce (add_comm (S n) 1) (hd v :: tl v)).
      rewrite (vector_length_coerce_cons _ (tl v)).
      reflexivity.
    + f_equal.
      * change (eq_rect _ _ _ _ _)
          with (vector_length_coerce (add_comm (S n) 1) (hd v :: tl v)).
        rewrite (vector_length_coerce_cons _ (tl v)).
        simpl; unfold most_.
        unfold vector_length_coerce.
        repeat f_equal.
        apply proof_irrelevance.
      * unfold last_ at 2.
        change (eq_rect _ _ _ _ _)
          with (vector_length_coerce (add_comm (S n) 1) (hd v :: tl v)).
        rewrite (vector_length_coerce_cons _ (tl v)).
        unfold last_, vector_length_coerce.
        simpl; repeat f_equal.
        apply proof_irrelevance.
Qed.

Theorem depEqLem : 
  forall (B : Type) 
         (F : B -> Type)
         (P : forall b : B, F b -> Prop)
         (b1 b2 : B) (eqb : b1 = b2)
         (p1 : F b1) (p2 : F b2),
         (rew eqb in p1 = p2) ->
         P b1 p1 ->
         P b2 p2.
Proof.
  intros B F P b1 b2 eqb.
  destruct eqb.
  intros p1 p2 eqp.
  destruct eqp.
  intros Pp.
  exact Pp.
Qed.         

Theorem t_snoc_ind : forall (A : Type) (P : forall n : nat, t A n -> Prop),
  P 0 [] ->
  (forall (h : A) (n : nat) (t : t A n), P n t -> P (n + 1) (t ++ [h])) ->
  forall (n : nat) (t : t A n), P n t.
Proof.
  intros A P Pnil Psnoc n t.
  induction n.
  - rewrite (vector_nil_eq t).
    exact Pnil.
  - remember (vector_length_coerce (eq_sym (add_comm n 1)) t) as t'.
    assert (t' = most_ t' ++ [last_ t']).
    { apply vector_snoc_eta. }
    assert (P n (most_ t')).
    { apply IHn. }
    apply (Psnoc (last_ t') _ _) in H0.
    assert (n + 1 = S n).
    { rewrite add_comm; reflexivity. }
    apply (depEqLem nat (Vector.t A) P (n + 1) (S n) H1 t' t).
    2: { rewrite H; assumption. }
    rewrite Heqt'.
    unfold vector_length_coerce.
    rewrite rew_compose.
    replace (Logic.eq_trans (eq_sym (add_comm n 1)) H1) with (eq_refl (S n)).
    + reflexivity.
    + apply proof_irrelevance.
Qed.

Theorem rev_append_step : forall {A n m}
  (h : A) (vn : Vector.t A n) (vm : Vector.t A m),
  rev_append (h :: vn) vm =
  vector_length_coerce (eq_sym (plus_n_Sm n m))
    (rev_append vn (h :: vm)).
Proof.
  intros A n m h vn vm.
  unfold rev_append.
  simpl rev_append_tail.
  unfold vector_length_coerce.
  unfold eq_rect_r.
  rewrite rew_compose.
  f_equal.
  apply proof_irrelevance.
Qed.

Theorem rev_append_unstep : forall {A n m}
  (h : A) (vn : Vector.t A n) (vm : Vector.t A m),
  rev_append vn (h :: vm) =
  vector_length_coerce (plus_n_Sm n m)
    (rev_append (h :: vn) vm).
Proof.
  intros A n m h vn vm.
  unfold rev_append.
  simpl rev_append_tail.
  unfold vector_length_coerce.
  unfold eq_rect_r.
  rewrite rew_compose.
  f_equal.
  apply proof_irrelevance.
Qed.

Theorem append_nil : forall {A n}
  (vn : Vector.t A n),
  vn ++ [] =
  vector_length_coerce (plus_n_O n) vn.
Proof.
  intros A n vn; induction vn.
  - rewrite vector_length_coerce_id.
    reflexivity.
  - simpl.
    rewrite IHvn.
    rewrite vector_length_coerce_cons.
    repeat f_equal.
    apply proof_irrelevance.
Qed.

Theorem vector_length_coerce_cons_in : forall {A n m}
  (eq : n = m) (h : A) (vn : Vector.t A n),
  h :: vector_length_coerce eq vn
  = vector_length_coerce (eq_S _ _ eq) (h :: vn).
Proof.
  intros A n m eq h vn.
  destruct eq.
  reflexivity.
Qed.

Theorem rev_append_app_step_lem : forall {n m},
  S (n + m) = (n + 1 + m).
Proof. lia. Qed.

Theorem rev_append_cons : forall {A n m}
  (h : A) (vn : Vector.t A n) (vm : Vector.t A m),
  rev_append (vn ++ [h]) vm =
  vector_length_coerce
    rev_append_app_step_lem
    (h :: rev_append vn vm).
Proof.
  intros A n m h vn vm.
  generalize dependent m.
  generalize dependent h.
  induction vn; intros.
  - simpl.
    replace (rev_append [h] vm)
       with (rev_append [] (h :: vm)).
    repeat rewrite vector_rev_append_nil_o.
    rewrite vector_length_coerce_id.
    reflexivity.
    rewrite rev_append_step.
    rewrite vector_length_coerce_id.
    reflexivity.
  - simpl. 
    rewrite rev_append_step.
    rewrite IHvn.
    rewrite rev_append_step.
    rewrite vector_length_coerce_cons_in.
    repeat rewrite vector_length_coerce_trans.
    f_equal; apply proof_irrelevance.
Qed.

Theorem rev_append_app : forall {A n m o}
  (vn : Vector.t A n) (vm : Vector.t A m) (vo : Vector.t A o),
  rev_append vn vm ++ vo =
  vector_length_coerce (add_assoc n m o)
    (rev_append vn (vm ++ vo)).
Proof.
  intros A n m o vn vm vo.
  generalize dependent m.
  generalize dependent o.
  induction vn; intros.
  - repeat rewrite vector_rev_append_nil_o.
    rewrite vector_length_coerce_id.
    reflexivity.
  - repeat rewrite rev_append_step.
    rewrite <- (vector_length_coerce_id (eq_refl o) vo) at 1.
    rewrite vector_length_coerce_app_funct.
    rewrite (IHvn _ vo _ (h :: vm)).
    repeat rewrite vector_length_coerce_trans.
    f_equal.
    apply proof_irrelevance.
Qed.

Theorem rev_append_app_2 : forall {A n m o}
  (vn : Vector.t A n) (vm : Vector.t A m) (vo : Vector.t A o),
  rev_append vn (vm ++ vo) =
  vector_length_coerce (eq_sym (add_assoc n m o))
    (rev_append vn vm ++ vo).
Proof.
  intros A n m o vn vm vo.
  rewrite rev_append_app.
  rewrite vector_length_coerce_trans.
  rewrite vector_length_coerce_id.
  reflexivity.
Qed.

Theorem rev_cons : forall {A n} (h : A) (v : Vector.t A n),
  rev (v ++ [h]) = 
  vector_length_coerce (add_comm 1 n) (h :: rev v).
Proof.
  intros A n h v.
  repeat rewrite rev_coerce_unfold.
  rewrite rev_append_cons.
  rewrite vector_length_coerce_cons_in.
  repeat rewrite vector_length_coerce_trans.
  f_equal.
  apply proof_irrelevance.
Qed.

Theorem rev_snoc : forall {A n} (h : A) (v : Vector.t A n),
  rev (h :: v) = 
  vector_length_coerce (add_comm n 1) (rev v ++ [h]).
Proof.
  intros A n h v.
  repeat rewrite rev_coerce_unfold.
  rewrite rev_append_step.
  rewrite <- (vector_length_coerce_id (eq_refl 1) [h]) at 2.
  rewrite vector_length_coerce_app_funct.
  rewrite (rev_append_app v [] [h]).
  simpl.
  repeat rewrite vector_length_coerce_trans.
  f_equal.
  apply proof_irrelevance.
Qed.

Theorem vector_length_coerce_f_swap : forall {A n m}
  (f : forall x, t A x -> t A x)
  (eq : n = m)
  (v : t A n),
  f _ (vector_length_coerce eq v) =
  vector_length_coerce eq (f _ v).
Proof.
  intros A n m f eq.
  destruct eq.
  reflexivity.
Qed.

Theorem vector_rev_rev_id : forall {A n}
  (v : Vector.t A n),
  rev (rev v) = v.
Proof.
  intros A n v; induction v using t_snoc_ind.
  - repeat rewrite vector_rev_nil_nil.
    reflexivity.
  - rewrite rev_cons.
    rewrite (vector_length_coerce_f_swap (@rev A)).
    rewrite rev_snoc, IHv,
            vector_length_coerce_trans,
            vector_length_coerce_id.
    reflexivity.
Qed.

Theorem vector_append_inv1 : forall {A n m}
    (v : Vector.t A (n + m)),
    uncurry Vector.append (Vector.splitat _ v) = v.
Proof.
  intros A n.
  induction n as [|n IHn];
  intros m.
  - intro; reflexivity.
  - intro v.
    simpl in v.
    destruct (vector_cons_split v) as [x [vtl eq]].
    rewrite eq.
    assert (uncurry Vector.append (Vector.splitat n vtl) = vtl).
    { apply IHn. }
    simpl.
    destruct (Vector.splitat n vtl) as [tl1 tl2].
    rewrite <- H.
    reflexivity.
Qed.

Theorem vector_append_inv2 : forall {A n m}
    (v1 : Vector.t A n) (v2 : Vector.t A m),
    Vector.splitat _ (Vector.append v1 v2) = (v1, v2).
  intros A n m v.
  generalize dependent m.
  induction v.
  - reflexivity.
  - simpl.
    intros m vs.
    rewrite IHv.
    reflexivity.
Qed.

Theorem vector_append_split : forall {A n m}
  (v : Vector.t A (n + m)), 
  (exists (vhd : Vector.t A n) (vtl : Vector.t A m),
  v = Vector.append vhd vtl).
Proof.
  intros A n m v.
  rewrite <- (vector_append_inv1 v).
  destruct (Vector.splitat n v) as [v1 v2].
  exists v1, v2.
  reflexivity.
Qed.

Definition vector_concat : forall {A n m},
    Vector.t (Vector.t A n) m -> Vector.t A (m * n).
  intros A n m v.
  induction v.
  - apply Vector.nil.
  - simpl.
    apply Vector.append.
    + apply h.
    + apply IHv.
Defined.

Definition vector_unconcat : forall {A n m},
    Vector.t A (m * n) -> Vector.t (Vector.t A n) m.
  intros A n m v.
  induction m as [|m IHm].
  - apply Vector.nil.
  - simpl in v; destruct (Vector.splitat _ v) as [vv1 vvtl].
    apply Vector.cons.
    + apply vv1.
    + apply IHm.
      apply vvtl.
Defined.

Theorem vector_concat_inv1_lem : forall {A n m}
  (v : Vector.t A (n * m))
  (u : Vector.t A m),
  vector_unconcat (Vector.append u v : Vector.t A (S n * m)) =
  Vector.cons _ u _ (vector_unconcat v).
Proof.
  intros A n m v u.
  generalize dependent v.
  induction u.
  - reflexivity.
  - intros v.
    simpl Vector.append.
    simpl vector_unconcat.
    rewrite vector_append_inv2.
    reflexivity.
Qed.

Theorem vector_concat_inv1 : forall {A n m}
  (v : Vector.t A (n * m)),
  vector_concat (vector_unconcat v) = v.
Proof.
  intros A n.
  induction n as [|n IHn];
  intros m v.
  - simpl.
    apply (Vector.case0 (fun v => Vector.nil A = v)).
    reflexivity.
  - simpl in v.
    destruct (vector_append_split v) as [vhd [vtl eq]].
    rewrite eq.
    rewrite vector_concat_inv1_lem.
    simpl.
    rewrite IHn.
    reflexivity.
Qed.

Theorem vector_concat_inv2 : forall {A n m}
    (v : Vector.t (Vector.t A n) m),
    vector_unconcat (vector_concat v) = v.
  intros A n m.
  induction v.
  - reflexivity.
  - simpl.
    rewrite vector_append_inv2.
    rewrite IHv.
    reflexivity.
Qed.

Definition vector_concat_2 : forall {A n m},
    Vector.t (Vector.t A n) m -> Vector.t A (n * m).
  intros A n m v.
  rewrite PeanoNat.Nat.mul_comm.
  apply vector_concat.
  assumption.
Defined.

Definition Block_Lem : forall idx blksz memsz,
    (idx < memsz) -> (blksz < memsz) ->
    { tl | memsz = idx + blksz + tl } + 
    { blk1 & { blk2 & { idx2 |
      blk1 + blk2 = blksz /\
      blk1 + idx2 = idx /\
      memsz = blk1 + idx2 + blk2 }}}.
    intros idx blksz memsz lim lbm.
    remember (memsz <? idx + blksz) as lm_ib.
    destruct lm_ib.
    - symmetry in Heqlm_ib.
      rewrite ltb_lt in Heqlm_ib.
      destruct (lt_sub Heqlm_ib) as [blk1 [Heq1 l0blk1]].
      right.
      exists blk1.
      destruct (lt_sub lim) as [blk2 [Heq2 l0blk2]].
      exists blk2.
      assert (blk1 < idx) as lb1_i.
      { lia. }
      destruct (lt_sub lb1_i) as [idx2 [Heqi l0idx2]].
      exists idx2.
      lia.
    - left.
      assert (not (memsz < idx + blksz)).
      { intro. rewrite <- ltb_lt in H.
        rewrite H in Heqlm_ib. discriminate Heqlm_ib. }
      clear Heqlm_ib.
      assert (memsz >= idx + blksz).
      { apply Compare_dec.not_lt. assumption. }
      destruct (le_sub H0) as [tl [Heq leotl]].
      exists tl.
      lia.
Defined.

Definition Block_Load_Store : forall {B memsz}
    (m : Vector.t B memsz)
    (idx blksz: fin memsz)
    (block : Vector.t B (proj1_sig blksz)),
    Vector.t B (proj1_sig blksz) * Vector.t B memsz.
  intros B memsz m [idx lip] [blksz lbp] block.
  destruct (Block_Lem _ _ _ lip lbp) as 
    [[tl eq]|[blk1[blk2[idx2[eq1 [eq2 eq3]]]]]].
  - rewrite eq in m.
    destruct (Vector.splitat _ m) as [m' m3].
    destruct (Vector.splitat _ m') as [m1 m2].
    split.
    { exact m2. }
    rewrite eq.
    exact (Vector.append (Vector.append m1 block) m3).
  - rewrite eq3 in m.
    destruct (Vector.splitat _ m) as [m' m3].
    destruct (Vector.splitat _ m') as [m1 m2].
    split.
    + apply (vector_length_coerce eq1).
      (* Note: m1 is an overflow, so it's
              bits are more significant than m3. *)
      rewrite add_comm.
      apply (Vector.append m3 m1).
    + rewrite <- eq1 in block.
      destruct (Vector.splitat _ block) as [block1 block2].
      rewrite eq3.
      (* Note: The overflow means block2 should go at
              the begining of memory, and block 1 at the end. *)
      assert (blk1 + idx2 + blk2 = blk2 + idx2 + blk1) as OvrEq.
      { lia. }
      rewrite OvrEq.
      exact (Vector.append (Vector.append block2 m2) block1).
Defined.

(* Memory_Block_Load w/o rebuilding memory. *)
Definition Block_Load : forall {B memsz}
    (m : Vector.t B memsz)
    (idx blksz: fin memsz),
    Vector.t B (proj1_sig blksz).
  intros B memsz m [idx lip] [blksz lbp].
  destruct (Block_Lem _ _ _ lip lbp) as 
    [[tl eq]|[blk1[blk2[idx2[eq1 [eq2 eq3]]]]]].
  - rewrite eq in m.
    destruct (Vector.splitat _ m) as [m' _].
    destruct (Vector.splitat _ m') as [_ m2].
    exact m2.
  - rewrite eq3 in m.
    destruct (Vector.splitat _ m) as [m' m3].
    destruct (Vector.splitat _ m') as [m1 _].
    apply (vector_length_coerce eq1).
    (* Note: m1 is an overflow, so it's
              bits are more significant than m3. *)
    rewrite add_comm.
    apply (Vector.append m3 m1).
Defined.

Definition Block_Store {B memsz}
    (m : Vector.t B memsz)
    (idx blksz: fin memsz)
    (block : Vector.t B (proj1_sig blksz)) :
    Vector.t B memsz :=
  snd (Block_Load_Store m idx blksz block).

Theorem vector_length_coerce_app_right_lem :
  forall n m o, m = o -> m + n = o + n.
Proof.
  intros n m o eq; destruct eq; reflexivity.
Qed.

Theorem vector_length_coerce_app_right : 
  forall {A n m o} (vn : Vector.t A n) (vm : Vector.t A m) (eq : m = o),
    vector_length_coerce eq vm ++ vn =
    vector_length_coerce (vector_length_coerce_app_right_lem n m o eq) (vm ++ vn).
Proof.
  intros A n m o vn vm eq; destruct eq.
  repeat rewrite vector_length_coerce_id.
  reflexivity.
Qed.

Theorem vector_length_coerce_app_left_lem :
  forall n m o, m = o -> n + m = n + o.
Proof.
  intros n m o eq; destruct eq; reflexivity.
Qed.

Theorem vector_length_coerce_app_left : 
  forall {A n m o} (vn : Vector.t A n) (vm : Vector.t A m) (eq : m = o),
    vn ++ vector_length_coerce eq vm =
    vector_length_coerce (vector_length_coerce_app_left_lem n m o eq) (vn ++ vm).
Proof.
  intros A n m o vn vm eq; destruct eq.
  repeat rewrite vector_length_coerce_id.
  reflexivity.
Qed.

Ltac vector_bubble :=
  match goal with
  | |- context[vector_length_coerce _ (vector_length_coerce _ _)] =>
      rewrite vector_length_coerce_trans
  | |- context[?x ++ vector_length_coerce _ ?y] =>
      rewrite <- vector_length_coerce_app_left
  | |- context[vector_length_coerce _ ?x ++ ?y] =>
      rewrite vector_length_coerce_app_right
  | |- context[?h :: vector_length_coerce _ ?y] =>
      rewrite (vector_length_coerce_cons_in _ h y)
  | |- context[(?vn ++ ?vm) ++ ?vo] =>
      rewrite <- (vector_length_coerce_app_assoc_1 vn vm vo)
  | |- context[rev []] =>
      rewrite vector_rev_nil_nil
  | |- context[rev (rev ?x)] =>
      rewrite (vector_rev_rev_id x)
  | |- context[rev (?h :: ?x)] =>
      rewrite (rev_snoc h x)
  | |- context[rev (?x ++ [?h])] =>
      rewrite (rev_cons h x)
  end.

Ltac vector_simp :=
  repeat vector_bubble;
  repeat rewrite vector_length_coerce_id.

Example test : rev [false ; false ; false ; false ; false ]
                 = [ false ; false ; false ; false ; false ].
Proof.
  vector_simp.
  reflexivity.
Qed.