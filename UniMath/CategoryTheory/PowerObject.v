(** ** 
  Following Saunders Mac Lane & Ieke Moerdijk 
  Sheaves in Geometry and Logic - A First Introduction to Topos theory.
  Chapter IV.1

  Contents :
  - The definition of [PowerObject];
	-	The definition of [PowerObject_functor];
	-	The derivation of [PowerObject_nat_z_iso],
      the natural (in a and b) (z-)isomorphism from Hom(b x a , Omega) to Hom(a,P b)
      (Omega is a subobject classifier) induced by the Power Object P;
	-	The derivation of [PowerObject_charname_nat_z_iso],
      the natural (z-)isomorphism from Hom(- , Omega) to Hom(1,P(-)) obtained from the one above choosing a = T (T is the Terminal Object);
*)

Require Import UniMath.Foundations.PartA.
Require Import UniMath.Foundations.PartD.

Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.Core.Isos.
Require Import UniMath.CategoryTheory.Core.NaturalTransformations.
Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.limits.binproducts.
Require Import UniMath.CategoryTheory.SubobjectClassifier.
Require Import UniMath.CategoryTheory.opp_precat.
Require Import UniMath.CategoryTheory.whiskering.
Require Import UniMath.CategoryTheory.PrecategoryBinProduct.
Require Import UniMath.CategoryTheory.OppositeCategory.Core.
Require Import UniMath.CategoryTheory.categories.HSET.Core.

Local Open Scope cat.

Section PowerObject_def.

  Context {C:category} {T:Terminal C} (Prod : BinProducts C) (O : subobject_classifier T).

  Local Notation "c 'x' d" :=
    (BinProductObject C (Prod c d))(at level 5).
  Local Notation "f ⨱ g" :=
    (BinProductOfArrows _ (Prod _ _) (Prod _ _) f g) (at level 10).

  Definition is_PowerObject
    (P : ob C ->  ob C)
    (inmap : ∏ (b:C), C ⟦b x (P b), O⟧ ):=
    ∏ (a b:C) (f : C ⟦b x a, O⟧),
      ∃! g : C ⟦a, P b⟧,
        f = identity b ⨱ g·(inmap b).

  Definition PowerObject :=
    ∑ (P : ob C ->  ob C)
      (inmap : ∏ (b:C), C ⟦b x (P b), O⟧ ),
      is_PowerObject P inmap.

  Definition make_PowerObject
    (P : ob C ->  ob C) (inmap : ∏ (b:C), C ⟦b x (P b), O⟧ ) (is : is_PowerObject P inmap)
    : PowerObject.
  Proof.
    use tpair.
    + exact P.
    + use tpair.
      - exact inmap.
      - exact is.
  Defined.

End PowerObject_def.

Section ContextAndNotaions.

Context {C:category} {T:Terminal C} {Prod : BinProducts C} {Ω : subobject_classifier T} (P: PowerObject Prod Ω).

Local Notation "c ⨉ d"
  := (BinProductObject C (Prod c d))(at level 5).
  (*\bigtimes*)

Local Notation "f ⨱ g"
  := (BinProductOfArrows _ (Prod _ _) (Prod _ _) f g) (at level 10).
  (*\timesbar*)

Section PowerObject_accessor.
  Definition PowerObject_on_ob : C -> C := pr1 P.
  Definition PowerObject_inPred
    : ∏ a : C, C ⟦(a ⨉ (PowerObject_on_ob a)), Ω⟧
    := pr1 (pr2 P).
  Definition PowerObject_property {a b : C}
    : ∏ f : C ⟦ b ⨉ a, Ω ⟧, ∃! g : C ⟦ a, PowerObject_on_ob b ⟧,
      f = (identity b) ⨱ g · PowerObject_inPred b
    := (pr2 (pr2 P)) a b.
  Definition PowerObject_transpose {a b : C} (f : C ⟦ b ⨉ a , Ω⟧)
    : C ⟦a , (PowerObject_on_ob b)⟧
    := pr1 ( iscontrpr1 ((pr2 (pr2 P)) a b f)).
  Definition PowerObject_transpose_tri {a b : C} (f : C ⟦ b ⨉ a , Ω⟧)
    : f = (identity b) ⨱ (PowerObject_transpose f)·
          PowerObject_inPred b
    := pr2 (iscontrpr1 ((pr2 (pr2 P)) a b f)).
End PowerObject_accessor.

Section PowerObject_transpose_lemma.

  Proposition PowerObject_transpose_precomp {a' a b: C} (g : C ⟦a', a⟧)(f : C ⟦(b ⨉ a), Ω⟧ )
    : PowerObject_transpose (identity b ⨱ g · f) = g · (PowerObject_transpose f).
  Proof.
    apply pathsinv0.
    use path_to_ctr.
    use pathsinv0.
    rewrite <-BinProductOfArrows_idxcomp.
    rewrite !assoc'.
    use cancel_precomposition.
    use pathsinv0.
    use (PowerObject_transpose_tri).
  Defined.

End PowerObject_transpose_lemma.

Section PowerObject_functor.

Let construction {c b : C} (h : C ⟦b,c⟧):=
  h ⨱ (identity (PowerObject_on_ob c))·(PowerObject_inPred c).

(*
  The PowerObject P induces a functor which maps object with PowerObject_on_ob
  and, given a morphism h, Ph is defined as the only morphism which makes
  the following diagram commute
  <<
                    h x id
            b x Pc --------> c x PC
            |                  |
    id x Ph |                  | inPred c
            v                  v
            b x Pb -------->   O
                  inPred b
  >>
  construction produces the upper composition
*)

Definition PowerObject_functor_data : functor_data C^op C.
Proof.
  use make_functor_data.
  - exact (PowerObject_on_ob).
  - intros c b h.
    use PowerObject_transpose.
    exact (construction h).
Defined.

Theorem PowerObject_functor_isfunctor : is_functor PowerObject_functor_data.
Proof.
  split.
  + intro b.
    use pathsinv0.
    use path_to_ctr.
    apply idpath.
  + unfold functor_compax.
    intros c b a h h'.
    cbn in c, b, a, h, h'.
    cbn.
    use pathsinv0.
    use path_to_ctr.
    cbn.
    unfold construction.
    rewrite <-(BinProductOfArrows_compxid), assoc'.
    fold (construction h).
    rewrite
      (PowerObject_transpose_tri (construction h)),
      assoc,
      BinProductOfArrows_comp,
      (id_right h'), <-(id_left h'),
      (id_left (PowerObject_transpose _)),
      <-(id_right (PowerObject_transpose _)).
    rewrite <-BinProductOfArrows_comp,
      !assoc',
      (PowerObject_transpose_tri
        (h' ⨱ (identity (PowerObject_on_ob b)) · PowerObject_inPred b)),
      assoc.
    use cancel_postcomposition.
    rewrite BinProductOfArrows_idxcomp.
    use BinProductArrowUnique.
    { rewrite
        id_right,
        BinProductOfArrowsPr1,
        id_right.
      apply idpath. }
    rewrite
      id_right,
      id_left,
      BinProductOfArrowsPr2.
    use cancel_precomposition.
    use cancel_postcomposition.
    use path_to_ctr.
    apply idpath.
Defined.

Definition PowerObject_functor : functor C^op C.
Proof.
  use make_functor.
  + exact PowerObject_functor_data.
  + exact PowerObject_functor_isfunctor.
Defined.

End PowerObject_functor.

(* In this section we show the natural isomorphis
from Hom ( -- x - , Ω) to Hom ( - , P(--) )*)
Section PowerObject_nat_z_iso.

(*The functor Hom ( -- x - , Ω)*)
Definition HomxO : functor (category_binproduct C^op C^op) hset_category
  :=( binswap_pair_functor ∙
      category_op_binproduct ∙
      (functor_opp (binproduct_functor Prod)) ∙
      (contra_homSet_functor Ω)).

(*The functor Hom ( - , P(--) )*)
Definition HomP : functor (category_binproduct C^op C^op) hset_category
  :=( pair_functor (functor_identity C^op) (PowerObject_functor) ∙
      homSet_functor).

Definition PowerObject_nt_data : nat_trans_data HomxO HomP.
Proof.
  intros ab f.
  use PowerObject_transpose.
  exact f.
Defined.

Theorem PowerObject_nt_is_nat_trans : is_nat_trans HomxO HomP PowerObject_nt_data.
Proof.
  intros (a,b) (a',b') (a'a,b'b).
  cbn in a'a, b'b.
  use funextfun.
  intro f.
  apply pathsinv0.
  use path_to_ctr.
  cbn.
  rewrite
    id_right,
    (PowerObject_transpose_tri f),
    assoc,
    BinProductOfArrows_comp,
    id_right.
  use (pathscomp0(b := (identity b') ⨱ (a'a · (PowerObject_transpose f))·
  b'b ⨱ (identity (_))·
  (PowerObject_inPred b)
  )).
  { use cancel_postcomposition.
    cbn.
    rewrite 
      BinProductOfArrows_comp,
      id_right,
      id_left.
    apply idpath. }
  apply pathsinv0.
  rewrite <-(PowerObject_transpose_tri f), <-BinProductOfArrows_idxcomp, !assoc'.
  use cancel_precomposition.
  use pathsinv0.
  use PowerObject_transpose_tri.
Qed.

Definition PowerObject_nattrans : nat_trans HomxO HomP.
Proof.
  use make_nat_trans.
  + exact PowerObject_nt_data.
  + exact PowerObject_nt_is_nat_trans.
Defined.

Theorem PowerObject_nt_is_nat_z_iso : is_nat_z_iso PowerObject_nattrans.
Proof.
  intros (a,b).
  cbn.
  use make_is_z_isomorphism.
  + intro g.
    exact ((identity b) ⨱ g · (PowerObject_inPred b)).
  + cbn.
    use make_is_inverse_in_precat.
    - use funextfun.
      intros f.
      cbn.
      use pathsinv0.
      use PowerObject_transpose_tri.
    - use funextfun.
      intros g.
      use pathsinv0.
      use path_to_ctr.
      use cancel_precomposition.
      apply idpath.
Defined.

Definition PowerObject_nat_z_iso : nat_z_iso HomxO HomP.
Proof.
  use make_nat_z_iso.
  + exact PowerObject_nattrans.
  + exact PowerObject_nt_is_nat_z_iso.
Defined.


(*in particolar, fixing (-) = T, we also get a natural isomorphism from from Hom(-,Ω) to Hom(T,P(-))*)

(*The natural transformation from (-)xT to (-) , with T the constant (terminal) functor*)
Definition idxT_nattrans := binproduct_nat_trans_pr1 C C Prod (functor_identity C) (constant_functor C C T).

Theorem idxT_is_nat_z_iso : is_nat_z_iso idxT_nattrans.
Proof.
  intro c.
  use is_z_iso_from_is_iso.
  use (terminal_binprod_unit_r T Prod).
Defined.

Definition idxT_nat_z_iso := (make_nat_z_iso _ _ (idxT_nattrans) (idxT_is_nat_z_iso)).

(*The natural transformation from (-)^op to ((-)xT)^op*)
Definition idxT_nat_inopp := op_nt idxT_nat_z_iso.

(*The natural transformation from Hom(-,Ω) to Hom( ((-)xT) , O ) *)
Definition idxT_whiskered_nat := post_whisker (idxT_nat_inopp) (contra_homSet_functor Ω).

(*The natural iso from Hom( - x T , Ω ) to Hom( T , P(-) ), with T terminal object*)
Definition PowerObject_nat_z_iso_Tfixed := nat_z_iso_fix_fst_arg C^op C^op hset_category _ _ PowerObject_nat_z_iso T.

(*composition yelds the nt from Hom(-,Ω) to Hom( T , P(-) )*)
Definition PowerObject_charname_nattrans := nat_trans_comp _ _ _ idxT_whiskered_nat PowerObject_nat_z_iso_Tfixed.

Definition PowerObject_charname_is_nat_z_iso : is_nat_z_iso PowerObject_charname_nattrans.
Proof.
  intro c.
  use is_z_iso_comp_of_is_z_isos.
  + generalize c.
    use post_whisker_z_iso_is_z_iso.
    use op_nt_is_z_iso.
    induction idxT_nat_z_iso as [idxT_nattrans Th].
    exact Th.
  + generalize c.
    induction PowerObject_nat_z_iso_Tfixed as [nattrans Th].
    exact Th.
Defined.

Definition PowerObject_charname_nat_z_iso : nat_z_iso (contra_homSet_functor Ω) (functor_fix_fst_arg C^op C^op hset_category HomP T).
Proof.
  use make_nat_z_iso.
  + exact PowerObject_charname_nattrans.
  + exact PowerObject_charname_is_nat_z_iso.
Defined.

Definition PowerObject_charname_nat_z_iso_tri {b : C} (f : C ⟦ b , Ω ⟧)
  : (identity b) ⨱ (PowerObject_charname_nat_z_iso b f)·
    PowerObject_inPred b
    = (BinProductPr1 C (Prod b T) · f).
Proof.
  rewrite (PowerObject_transpose_tri).
  cbn.
  unfold PowerObject_nt_data, binproduct_nat_trans_pr1_data.
  cbn.
  rewrite id_right.
  apply idpath.
Defined.

End PowerObject_nat_z_iso.

End ContextAndNotaions.