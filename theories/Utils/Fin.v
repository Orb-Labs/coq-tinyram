(** * Finite types *)

(* [fin n : Type] is a type with [n] inhabitants. It is isomorphic to
   [Coq.Vector.Fin.t] from the standard library, but we found this formulation
   easier to reason about. *)

(* In this compiler, we use [fin n] as the type of "block labels" in [Asm]
   programs (program locations that can be jumped to). In an earlier version, labels
   could be any type, but this restriction makes [Asm] programs easier to introspect
   for defining optimizations (though the current development doesn't make use of it).
  *)

(* The instances at the end derive categorical operations for the subcategories of
   [Fun] and [ktree] on finite types (instead of arbitrary types). *)

(* begin hide *)
From Coq Require Import
     Arith
     Lia.
Import PeanoNat.Nat EqNotations.

From ITree Require Import
     ITree
     ITreeFacts
     Basics.Category
     Basics.CategorySub.

From TinyRAM.Utils Require Import
  Arith.
(* end hide *)

(* Type with [n] inhabitants. *)
Definition fin (n : nat) : Type := { x : nat | x < n }.

(* Hide proof terms. *)
(* N.B.: [x < n] unfolds to [S x < n], which is why we don't make the first
   field more precise. *)
Notation fi' i := (exist (fun j : nat => _) i _).

Program Definition f0 {n} : fin (S n) := fi' 0.
Next Obligation. lia. Defined.

Lemma unique_fin : forall n (i j : fin n),
    proj1_sig i = proj1_sig j -> i = j.
Proof.
  intros ? [] [] w. simpl in w; destruct w. f_equal; apply le_unique.
Qed.

Lemma unique_f0 : forall (a : fin 1), a = f0.
Proof.
  destruct a. apply unique_fin; simpl. lia.
Qed.

Program Definition fS {n} : fin n -> fin (S n) :=
  fun i => fi' (S (proj1_sig i)).
Next Obligation.
  destruct i; simpl; lia.
Defined.

Lemma fin_0 {A} : fin 0 -> A.
Proof.
  intros [].
  apply PeanoNat.Nat.nlt_0_r in l.
  contradiction.
Qed.

Instance FinInitial {E} : Initial (sub (ktree E) fin) 0 := fun _ => fin_0.

Lemma split_fin_helper:
  forall n m x : nat, x < n + m -> ~ x < n -> x - n < m.
Proof.
  intros n m x l n0.
  lia.
Defined.

Program Definition split_fin_sum (n m : nat)
  : fin (n + m) -> (fin n) + (fin m) := fun x =>
    match lt_dec (proj1_sig x) n with
    | left _ => inl (fi' (proj1_sig x))
    | right _ => inr (fi' (proj1_sig x - n))
    end.
Next Obligation.
  apply split_fin_helper. eapply proj2_sig. assumption.
Defined.

Program Definition L {n} (m : nat) (a : fin n) : fin (n + m) := _.
Next Obligation.
  destruct a.
  exists x. apply PeanoNat.Nat.lt_lt_add_r.  assumption.
Defined.

Program Definition R {m} (n:nat) (a:fin m) : fin (n + m) := _.
Next Obligation.
  destruct a.
  exists (n + x). lia.
Defined.

Lemma R_0_a : forall (n:nat) (a : fin n), R 0 a = a.
Proof.
  intros; destruct a; apply unique_fin; reflexivity.
Qed.

Lemma R_1_a : forall (n:nat) (a : fin n), R 1 a = fS a.
Proof.
  intros; destruct a; apply unique_fin; reflexivity.
Qed.

Lemma split_fin_sum_0_a : forall m (a : fin (0 + m)),
    (@split_fin_sum 0 m a) = inr a.
Proof.
  intros.
  unfold split_fin_sum, split_fin_sum_obligation_1.
  destruct (Compare_dec.lt_dec _ 0) as [H | H].
  - inversion H.
  - f_equal. destruct a; apply unique_fin. simpl; lia.
Qed.

Lemma split_fin_sum_FS_inr :
  (@split_fin_sum (S O) (S O) (fS f0) = inr f0).
Proof.
  cbn; f_equal; apply unique_f0.
Qed.

Lemma split_fin_sum_f1_inl :
  (@split_fin_sum 1 1 (@f0 1)) = inl f0.
Proof.
  cbn; f_equal; apply unique_f0.
Qed.

Lemma L_1_f1 : (L 1 (@f0 0)) = f0.
Proof.
  apply unique_fin; reflexivity.
Qed.

Lemma split_fin_sum_L_L_f1 :
  (@split_fin_sum _ _ (L 1 (L 1 (@f0 0)))) = inl f0.
Proof.
  cbn; f_equal; apply unique_fin; reflexivity.
Qed.

Lemma split_fin_sum_R_2 : split_fin_sum 2 1 (R 2 (@f0 0)) = inr f0.
Proof.
  cbn; f_equal; apply unique_fin; reflexivity.
Qed.

Lemma split_fin_sum_R n m (x : fin m) : split_fin_sum n m (R n x) = inr x.
Proof.
  destruct x; simpl. unfold split_fin_sum; simpl.
  destruct lt_dec.
  - exfalso. lia.
  - f_equal. apply unique_fin; simpl; lia.
Qed.

Lemma split_fin_sum_L n m (x : fin n) : split_fin_sum n m (L m x) = inl x.
Proof.
  destruct x; simpl. unfold split_fin_sum; simpl.
  destruct lt_dec.
  - f_equal. apply unique_fin; simpl; lia.
  - exfalso. lia.
Qed.

Definition merge_fin_sum (n m: nat) : fin n + fin m -> fin (n + m) :=
  fun v =>
    match v with
    | inl v => L m v
    | inr v => R n v
    end.

Lemma merge_fin_sum_inr : (merge_fin_sum 1 1 (inr f0)) = (fS f0).
Proof.
  apply unique_fin; reflexivity.
Qed.

Lemma merge_fin_sum_inl_1 f : (merge_fin_sum 1 1 (inl f)) = f0.
Proof.
  rewrite (unique_f0 f); apply unique_fin; reflexivity.
Qed.

Lemma merge_split:
  forall (n m : nat) (a : fin (n + m)), merge_fin_sum n m (split_fin_sum n m a) = a.
Proof.
  intros n m []. unfold split_fin_sum; simpl.
  destruct (lt_dec x n); apply unique_fin; simpl; reflexivity + lia.
Qed.

Lemma split_merge:
  forall (n m : nat) (a : fin n + fin m), split_fin_sum n m (merge_fin_sum n m a) = a.
Proof.
  intros n m [[] | []]; unfold split_fin_sum; simpl; destruct lt_dec; simpl;
    try (f_equal; apply unique_fin; simpl; reflexivity + lia);
    try contradiction + exfalso; lia.
Qed.

Definition fin_mod : forall n m,
  n <> 0 -> fin (m * n) -> fin n.
  intros n m meq f.
  destruct f as [f fprp].
  exists (f mod n).
  apply mod_upper_bound.
  assumption.
Defined.

Instance ToBifunctor_ktree_fin {E} : ToBifunctor (ktree E) fin sum Nat.add :=
  fun n m y => Ret (split_fin_sum n m y).

Instance FromBifunctor_ktree_fin {E} : FromBifunctor (ktree E) fin sum Nat.add :=
  fun n m y => Ret (merge_fin_sum n m y).

Instance IsoBif_ktree_fin {E}
  : forall a b, Iso (ktree E) (a := fin (Nat.add a b)) to_bif from_bif.
Proof.
  unfold to_bif, ToBifunctor_ktree_fin, from_bif, FromBifunctor_ktree_fin.
  constructor; intros x.
  - unfold cat, Cat_sub, Cat_Kleisli. cbn. rewrite bind_ret_l.
    apply eqit_Ret, merge_split.
  - unfold cat, Cat_sub, Cat_Kleisli. cbn. rewrite bind_ret_l.
    apply eqit_Ret, split_merge.
Qed.

Instance ToBifunctor_Fun_fin : ToBifunctor Fun fin sum Nat.add :=
  fun n m y => split_fin_sum n m y.

Instance FromBifunctor_Fun_fin : FromBifunctor Fun fin sum Nat.add :=
  fun n m y => merge_fin_sum n m y.

Instance IsoBif_Fun_fin
  : forall a b, Iso Fun (a := fin (Nat.add a b)) to_bif from_bif.
Proof.
  constructor; intros x.
  - apply merge_split.
  - apply split_merge.
Qed.

Instance InitialObject_ktree_fin {E} : InitialObject (sub (ktree E) fin) 0.
Proof.
  intros n f x; apply fin_0; auto.
Qed.

Definition fin_add : forall {n m} (f1 : fin n) (f2 : fin m), fin (n + m - 1).
  intros n m [f1 f1P] [f2 f2P].
  exists (f1 + f2).
  destruct n. { lia. }
  destruct m. { lia. }
  lia.
Defined.

Definition fin_cast : forall {n m}, (n <= m) -> fin n -> fin m.
  intros n m le [f fP].
  exists f.
  lia.
Defined.

Theorem fin_mul_lem : forall {n m},
  (n - 1) * (m - 1) <= S (n * m - m - n).
Proof.
  intros n m.
  rewrite mul_sub_distr_l.
  repeat rewrite mul_sub_distr_r.
  rewrite mul_1_r, mul_1_l; simpl.
  destruct n. { simpl; lia. }
  destruct m. { rewrite <- mult_n_O; simpl; lia. }
  destruct n. { simpl; rewrite add_0_r, sub_diag; lia. }
  destruct m. { simpl; rewrite mul_1_r, sub_diag; lia. }
  rewrite add_sub_distr. 2: { lia. }
  2: { apply le_add_le_sub_r, add_le_mul; lia. }
  rewrite add_1_r; apply le_n.
Qed.

Definition fin_mul : forall {n m} (f1 : fin n) (f2 : fin m),
                            fin (S (S (n * m - m - n))).
  intros n m [f1 f1P] [f2 f2P].
  exists (f1 * f2).
  apply (le_lt_trans _ ((n - 1) * (m - 1))).
  + apply mul_le_mono.
    - rewrite <- lt_succ_r.
      replace (S (n - 1)) with n. { assumption. }
      lia.
    - rewrite <- lt_succ_r.
      replace (S (m - 1)) with m. { assumption. }
      lia.
  + apply (le_lt_trans _ (S (n * m - m - n))).
    - apply fin_mul_lem.
    - lia.
Defined.

Definition fin_max : forall n, fin (S n).
  intro n; exists n; lia.
Defined.

Theorem proj1_fin_cast : forall {n m} (f : fin n) (eq : n <= m),
  proj1_sig (fin_cast eq f) = proj1_sig f.
Proof. destruct f; reflexivity. Qed.

Theorem proj1_fin_add : forall {n m} (f : fin n) (g : fin m),
  proj1_sig (fin_add f g) = proj1_sig f + proj1_sig g.
Proof. destruct f, g; reflexivity. Qed.

Theorem proj1_fin_mul : forall {n m} (f : fin n) (g : fin m),
  proj1_sig (fin_mul f g) = proj1_sig f * proj1_sig g.
Proof. destruct f, g; reflexivity. Qed.

Theorem proj1_fin_max : forall {n},
  proj1_sig (fin_max n) = n.
Proof. reflexivity. Qed.

Theorem fin_rew : forall {n m o} (eq : n = m) (H : o < n),
  (rew eq in (exist (fun x => x < n) o H : fin n)) =
  exist (fun x => x < m) o (rew eq in H).
Proof. intros n m o eq; destruct eq; reflexivity. Qed.
