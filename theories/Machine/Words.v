From Coq Require Import
  Lia VectorEq.
From TinyRAM.Utils Require Import
  Vectors.
From TinyRAM.Utils Require Import
  BitVectors.
From TinyRAM.Utils Require Import
  Fin.
From TinyRAM.Machine Require Import
  Parameters.
Import PeanoNat.Nat.

Module TinyRAMWords (Params : TinyRAMParameters).
  Import Params.
  Export Params.

  (*"""
  each Word consists of [wordSize] bits
  """*)
  Definition Word := Vector.t bool wordSize.

  Definition wcast (v : Word) := 
    cast v (eq_sym (succ_pred_pos _ wordSizePos)).

  (*Registers can be cleanly split into bytes.*) 
  Definition RegisterBytes (r : Word) : 
    Vector.t Byte wordSizeEighth :=
    vector_unconcat r.

  Definition BytesRegister (v : Vector.t Byte wordSizeEighth) : Word 
    := vector_concat v.

  Theorem RegisterBytesIso1 :
    forall (r : Word), 
    BytesRegister (RegisterBytes r) = r.
  Proof.
    intros r.
    unfold RegisterBytes, BytesRegister.
    rewrite vector_concat_inv1.
    reflexivity.
  Qed.

  Theorem RegisterBytesIso2 :
    forall (v : Vector.t Byte wordSizeEighth), 
    RegisterBytes (BytesRegister v) = v.
  Proof.
    intros r.
    unfold RegisterBytes, BytesRegister.
    rewrite vector_concat_inv2.
    reflexivity.
  Qed.

End TinyRAMWords.


