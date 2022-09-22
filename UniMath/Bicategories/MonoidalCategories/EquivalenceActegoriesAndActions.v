Require Import UniMath.Foundations.All.
Require Import UniMath.MoreFoundations.All.

Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.Core.Isos.
Require Import UniMath.CategoryTheory.Core.NaturalTransformations.
Require Import UniMath.CategoryTheory.FunctorCategory.
Require Import UniMath.CategoryTheory.categories.StandardCategories.
Require Import UniMath.CategoryTheory.DisplayedCats.Core.
Require Import UniMath.CategoryTheory.DisplayedCats.Functors.
Require Import UniMath.CategoryTheory.DisplayedCats.Total.

Require Import UniMath.CategoryTheory.DisplayedCats.Constructions.

Require Import UniMath.Bicategories.Core.Bicat.
Require Import UniMath.Bicategories.Core.Invertible_2cells.
Require Import UniMath.Bicategories.Core.Examples.BicatOfCats.

Require Import UniMath.Bicategories.DisplayedBicats.DispBicat.

Require Import UniMath.CategoryTheory.Monoidal.WhiskeredBifunctors.
Require Import UniMath.CategoryTheory.Monoidal.MonoidalCategoriesWhiskered.
Require Import UniMath.CategoryTheory.Monoidal.MonoidalFunctorsWhiskered.

Require Import UniMath.CategoryTheory.Monoidal.Actegories.
Require Import UniMath.CategoryTheory.Monoidal.MorphismsOfActegories.

Require Import UniMath.Bicategories.MonoidalCategories.BicatOfActegories.
Require Import UniMath.Bicategories.MonoidalCategories.BicatOfActionsInBicat.

Require Import UniMath.Bicategories.MonoidalCategories.WhiskeredMonoidalFromBicategory.

Require Import UniMath.Bicategories.PseudoFunctors.Display.PseudoFunctorBicat.
Require Import UniMath.Bicategories.PseudoFunctors.PseudoFunctor.
Require Import UniMath.Bicategories.PseudoFunctors.Biequivalence.

Import BifunctorNotations.

Section FunctorsIntoEndofunctorCategory.

  Require Import UniMath.CategoryTheory.FunctorCategory.

  Import BifunctorNotations.

  Lemma bifunctor_to_functorintoendofunctorcat
        {C D E : category} (F : bifunctor C D E)
    : functor C [D,E].
  Proof.
    use make_functor.
    - exists (λ c, leftwhiskering_functor F (bifunctor_leftid F) (bifunctor_leftcomp F) c).
      intros c1 c2 f.
      exists (λ d, f ⊗^{F}_{r} d).
      exact (λ d1 d2 g, ! bifunctor_equalwhiskers F c1 c2 d1 d2 f g).
    - use tpair.
      + intro c.
        use total2_paths_f.
        * apply funextsec ; intro d.
          apply bifunctor_rightid.
        * repeat (apply funextsec ; intro).
          apply homset_property.
      + intros c1 c2 c3 f g.
        use total2_paths_f.
        * apply funextsec ; intro.
          apply bifunctor_rightcomp.
        * repeat (apply funextsec ; intro).
          apply homset_property.
  Defined.

  Lemma bifunctor_from_functorintoendofunctorcat
        {C D E : category} (F : functor C [D,E])
    : bifunctor C D E.
  Proof.
    use make_bifunctor.
    - exists (λ c d, pr1 (F c) d).
      exists (λ c d1 d2 g, #(pr1 (F c)) g).
      exact (λ d c1 c2 f, pr1 (#F f) d).
    - repeat (use tpair).
      + intro ; intro ; apply functor_id.
      + exact (λ d c, toforallpaths _ _ _ (maponpaths pr1 (functor_id F c)) d).
      + intro ; intros ; apply functor_comp.
      + intro ; intros.
        exact (toforallpaths _ _ _ (maponpaths pr1 (functor_comp F f1 f2)) b).
      + intro ; intros.
        exact (! pr2 (#F f) b1 b2 g).
  Defined.

  Lemma bifunctor_to_from {C D E : category} (F : bifunctor C D E)
    : bifunctor_from_functorintoendofunctorcat (bifunctor_to_functorintoendofunctorcat F) = F.
  Proof.
    use total2_paths_f.
    2: { apply isaprop_is_bifunctor. }
    apply idpath.
  Defined.

  Lemma bifunctor_from_to {C D E : category} (F : functor C [D,E])
    : bifunctor_to_functorintoendofunctorcat (bifunctor_from_functorintoendofunctorcat F) = F.
  Proof.
    use functor_eq.
    { apply homset_property. }
    use total2_paths_f.
    { apply idpath. }
    repeat (apply funextsec ; intro).
    use total2_paths_f.
    { apply idpath. }
    repeat (apply funextsec ; intro).
    apply pathsinv0inv0.
  Defined.

  Lemma bifunctor_equiv_functorintoendofunctorcat (C D E : category)
    : bifunctor C D E ≃ functor C [D,E].
  Proof.
    use weq_iso.
    { apply bifunctor_to_functorintoendofunctorcat. }
    { apply bifunctor_from_functorintoendofunctorcat. }
    { intro ; apply bifunctor_to_from. }
    { intro ; apply bifunctor_from_to. }
  Defined.

End FunctorsIntoEndofunctorCategory.

Section ActegoryToObject.

  Context {V : category} (Mon_V : monoidal V).
  Context {C : category}.

  Definition fmonoidal_data_to_object
             (act : actegory Mon_V C)
    : fmonoidal_data
        (monoidal_swapped Mon_V)
        (monoidal_from_bicat_and_ob (C : bicat_of_cats))
        (bifunctor_to_functorintoendofunctorcat act).
  Proof.
    split.
    - intros v w.
      exists (λ c, actegory_actorinvdata act w v c).
      intros v1 w1 f.
      apply actorinv_nat_leftwhisker.
    - exists (λ v, actegory_unitorinvdata act v).
      intros v w f.
      exact (! actegory_unitorinvnat Mon_V act v w f).
  Defined.

  Definition fmonoidal_laxlaws_to_object
             (act : actegory Mon_V C)
    : fmonoidal_laxlaws (fmonoidal_data_to_object act).
  Proof.
    repeat split ; (intro ; intros ; apply nat_trans_eq ; [apply homset_property | intro ; cbn ]).
    - apply actorinv_nat_rightwhisker.
    - apply actorinv_nat_leftrightwhisker.
    - rewrite id_left.
      apply pentagon_identity_actorinv.
    - rewrite (! actegory_triangleidentity Mon_V act x x0).
      rewrite assoc.
      etrans. {
        apply maponpaths_2.
        rewrite assoc'.
        apply maponpaths.
        exact (pr2 (actegory_actorisolaw Mon_V act x (monoidal_unit Mon_V) x0)).
      }
      rewrite id_right.
      rewrite (! bifunctor_leftcomp _ _ _ _ _ _ _).
      etrans. {
        apply maponpaths.
        apply actegory_unitorisolaw.
      }
      apply bifunctor_leftid.
    - admit.
  Admitted.

  Definition fmonoidal_lax_to_object
             (act : actegory Mon_V C)
    : fmonoidal_lax
        (monoidal_swapped Mon_V)
        (monoidal_from_bicat_and_ob (C : bicat_of_cats))
        (bifunctor_to_functorintoendofunctorcat act)
    := fmonoidal_data_to_object act ,, fmonoidal_laxlaws_to_object act.

  Definition fmonoidal_stronglaws_to_object (Act : actegory Mon_V C)
    : fmonoidal_stronglaws
        (pr1 (fmonoidal_data_to_object Act))
        (pr2 (fmonoidal_data_to_object Act)).
  Proof.
    repeat (use tpair).
    - intros v w.
      use tpair.
      + exists (λ c, actegory_actordata Act w v c).
        intros c1 c2 f.
        cbn.
        apply (! actegory_actornatleft _ _ _ _ _ _ _ ).
      + use tpair.
        * apply nat_trans_eq.
          { apply homset_property. }
          intro.
          apply actegory_actorisolaw.
        * apply nat_trans_eq.
          { apply homset_property. }
          intro.
          apply (pr1 (actegory_actorisolaw Mon_V Act w v x)).
    - exact (λ c, actegory_unitordata Act c).
    - intros c1 c2 f.
      cbn.
      apply actegory_unitornat.
    - use nat_trans_eq.
      { apply homset_property. }
      intro.
      cbn.
      apply actegory_unitorisolaw.
    - use nat_trans_eq.
      { apply homset_property. }
      intro.
      cbn.
      apply actegory_unitorisolaw.
  Defined.

  Definition actegory_to_object (Act : actegory Mon_V C)
    : bicatactionbicat (monoidal_swapped Mon_V) bicat_of_cats.
  Proof.
    exists C.
    exists (bifunctor_to_functorintoendofunctorcat Act).
    exists (fmonoidal_lax_to_object Act).
    exact (fmonoidal_stronglaws_to_object Act).
  Defined.

End ActegoryToObject.

Section ActegoryFromObject.

  Context {V : category}.
  Context (Mon_V : monoidal V).

  Context (C : bicatactionbicat Mon_V bicat_of_cats).

  Local Notation action_C := (pr12 C).
  Local Notation action_fmon_lax := (pr122 C).
  Local Notation action_fmon_strong := (pr222 C).

  Definition unitor_from_object
    :  action_unitor_data Mon_V (bifunctor_from_functorintoendofunctorcat action_C).
  Proof.
    intro ; apply (pr12 action_fmon_strong).
  Defined.

  Definition unitorinv_from_object
    : action_unitorinv_data Mon_V (bifunctor_from_functorintoendofunctorcat action_C).
  Proof.
    intro ; apply (fmonoidal_preservesunit action_fmon_lax).
  Defined.

  Definition actor_from_object
    : actor_data (monoidal_swapped Mon_V) (bifunctor_from_functorintoendofunctorcat action_C)
    := λ v w c, pr11 (pr1 action_fmon_strong w v) c.

  Definition actorinv_from_object
    : actorinv_data (monoidal_swapped Mon_V) (bifunctor_from_functorintoendofunctorcat action_C)
    := λ v w c, pr1 (fmonoidal_preservestensordata (pr122 C) w v) c.

  Definition actegory_data_from_object
    : actegory_data (monoidal_swapped Mon_V) (pr1 C).
  Proof.
    exists (bifunctor_from_functorintoendofunctorcat action_C).
    exists unitor_from_object.
    exists unitorinv_from_object.
    exists actor_from_object.
    exact actorinv_from_object.
  Defined.

  Definition actegory_laws_from_object
    : actegory_laws (monoidal_swapped Mon_V) actegory_data_from_object.
  Proof.
    repeat split.
    - intro ; intros.
      cbn.
      unfold unitor_from_object.
      cbn.
      admit.
    - apply (toforallpaths _ _ _ (base_paths _ _ (pr222 action_fmon_strong))).
    - apply (toforallpaths _ _ _ (base_paths _ _ (pr122 action_fmon_strong))).
    - intro ; intros.
      cbn.
      cbn in C.
      unfold fmonoidal in C.
      admit.
    - intro ; intros.
      cbn.
      admit.
    - intro ; intros.
      cbn.
      admit.
    - apply (toforallpaths _ _ _ (base_paths _ _ (pr22 (pr1 action_fmon_strong w v)))).
    - apply (toforallpaths _ _ _ (base_paths _ _ (pr12 (pr1 action_fmon_strong w v)))).
    - intro ; intros.
      cbn.
      admit.
    - intro ; intros.
      cbn.
      admit.
  Admitted.

  Definition actegory_from_object
    : actegory (monoidal_swapped Mon_V) (pr1 C)
    := actegory_data_from_object ,, actegory_laws_from_object.

End ActegoryFromObject.

Context {V : category} (Mon_V : monoidal V).

Local Definition ACAT
  : bicat := actbicat Mon_V.

Local Definition ACTI
  : bicat := bicatactionbicat (monoidal_swapped Mon_V) bicat_of_cats.

Section FromActegoriesToActionsInCat.

  Definition acat_to_acti_on_ob : (ob ACAT) -> (ob ACTI)
    := λ act, actegory_to_object Mon_V (pr2 act).

  Lemma TODO (A : UU) : A.
  Proof.
  Admitted.

  Definition acat_to_acti_on_mor
             {a1 a2 : ACAT} (f : ACAT⟦a1,a2⟧)
    : ACTI⟦actegory_to_object Mon_V (pr2 a1), actegory_to_object Mon_V (pr2 a2)⟧.
  Proof.
    exists (pr1 f).
    repeat (use tpair).
    - intro v.
      exists (λ c, pr11 (pr2 f) v c).
      abstract (exact (λ c1 c2 g, pr1 (pr212 f) v c1 c2 g)).
    - intros v w g.
      use nat_trans_eq.
      { apply homset_property. }
      intro c.
      cbn.
      etrans. {
        do 2 apply maponpaths_2.
        apply (bifunctor_leftid (pr12 a2)).
      }
      etrans. { apply maponpaths_2 ; apply id_left. }.
      etrans. 2: { apply maponpaths ; apply (! id_right _). }.
      exact (pr12 (pr212 f) v w c g).
    - use total2_paths_f.
        2: { apply isaprop_is_nat_trans ; apply homset_property. }

        apply funextsec ; intro c.
        cbn.
        etrans.
        2: {
          apply maponpaths_2.
          apply (! id_left _).
        }
        etrans.
        2: { apply (! id_left _). }
        cbn in f.
        unfold lineator in f.
        unfold lineator_lax in f.
        unfold lineator_laxlaws in f.
        unfold preserves_unitor in f.
        unfold lineator_strongly in f.
        cbn in a1.
        Check actegory_triangleidentity Mon_V (pr2 a2) _.

        apply TODO. (*** TODO ***)
    -
      intros v w.
      use nat_trans_eq.
      { apply homset_property. }
      intro c.
      cbn.
      rewrite ! id_left.

      apply TODO. (*** TODO ***)
  Defined.

  Definition acat_to_acti_data
    : psfunctor_data ACAT ACTI.
  Proof.
    use make_psfunctor_data.
    - exact acat_to_acti_on_ob.
    - exact (λ a1 a2 f, acat_to_acti_on_mor f).
    - intros a1 a2 f g α.
      exists (pr1 α).
      intro v.
      use nat_trans_eq.
      { apply homset_property. }
      exact (λ c, pr2 α v c).
    - intro a.
      use tpair.
      + apply nat_trans_id.
      + intro v.
        use nat_trans_eq.
        { apply homset_property. }
        intro c.
        cbn ;
        unfold identity_lineator_data ;
        rewrite ! id_left ;
        rewrite id_right ;
        apply (! bifunctor_leftid _ _ _).
    - intros a1 a2 a3 f g.
      use tpair.
      {  simpl. apply nat_trans_id. }
      intro v.
      use nat_trans_eq.
      { apply homset_property. }
      intro c.
      cbn.
      rewrite bifunctor_leftid.
      rewrite ! id_left.
      rewrite ! id_right.
      apply idpath.
  Defined.

  Definition acat_to_acti_laws
    : psfunctor_laws acat_to_acti_data.
  Proof.
    repeat split ;
      (intro ; intros ; use total2_paths_f ;
       [try (apply idpath) ; try (use nat_trans_eq ; [apply homset_property | intro ; cbn ])
       | apply proofirrelevance ; (apply impred_isaprop ; intro) ; apply cellset_property]).
    - rewrite ! id_right ; apply (! functor_id _ _).
    - rewrite ! id_right ; apply idpath.
    - rewrite ! id_right ; rewrite (! functor_id _ _) ; rewrite id_left ; apply idpath.
    - rewrite id_left ; apply (! id_right _).
    - rewrite id_left ; apply (! id_right _).
  Qed.

  Definition acat_to_acti_invertible_cells
    : invertible_cells acat_to_acti_data.
  Proof.
    use tpair.
    - intro.
      use tpair.
      + use tpair.
        * apply nat_trans_id.
        * intro.
          use total2_paths_f.
          2: {
            apply proofirrelevance.
            apply isaprop_is_nat_trans.
            apply homset_property.
          }
          simpl.
          apply funextsec ; intro.
          rewrite ! id_right.
          apply (! bifunctor_leftid _ _ _).
      + use tpair.
        * use total2_paths_f.
          -- use nat_trans_eq.
             { apply homset_property. }
             intro.
             apply id_right.
          -- apply proofirrelevance.
             apply impred_isaprop ; intro.
             apply cellset_property.
        * use total2_paths_f.
          -- use nat_trans_eq.
             { apply homset_property. }
             intro.
             apply id_right.
          -- apply proofirrelevance.
             apply impred_isaprop ; intro.
             apply cellset_property.
    - intro ; intros.
      use tpair.
      + use tpair.
        * apply nat_trans_id.
        * intro.
          use total2_paths_f.
          2: {
            apply proofirrelevance.
            apply isaprop_is_nat_trans.
            apply homset_property.
          }
          simpl.
          apply funextsec ; intro.
          rewrite ! id_right.
          rewrite ! id_left.
          rewrite bifunctor_leftid.
          apply (! id_left _).
      + use tpair ;
          (use total2_paths_f
           ; [
              use nat_trans_eq ;
              [ apply homset_property
              | intro ; apply id_right ]
            |
              apply proofirrelevance ;
              apply impred_isaprop ; intro ;
              apply cellset_property
          ]).
  Qed.

  Definition acat_to_acti
    : psfunctor ACAT ACTI.
  Proof.
    use make_psfunctor.
    - exact acat_to_acti_data.
    - exact acat_to_acti_laws.
    - exact acat_to_acti_invertible_cells.
  Defined.

End FromActegoriesToActionsInCat.

Section FromActionInCatToActegories.

  Definition acti_to_acat_on_ob : (ob ACTI) -> (ob ACAT)
    := λ act, _ ,, actegory_from_object _ act.

  Definition acti_to_acat_on_mor
  {a1 a2 : ACTI} (f : ACTI⟦a1,a2⟧)
    : ACAT ⟦ acti_to_acat_on_ob a1, acti_to_acat_on_ob a2⟧.
  Proof.
    exists (pr1 f).
    repeat (use tpair).
    - exact (λ v c, pr1 (pr112 f v) c).
    - intros v c1 c2 g.
      exact (pr2 (pr112 f v) c1 c2 g).
    - intros v w c g.
      refine (_ @ toforallpaths _ _ _ (base_paths _ _ (pr212 f v w g)) c @ _).
      + simpl.
        apply maponpaths_2.
        etrans.
        2: {
          apply maponpaths_2.
          apply (! functor_id _ _).
        }
        apply (! id_left _).
      + etrans. { apply assoc. }
        apply id_right.
    - intros v w c.
      cbn.
      apply TODO.
    - intro c.
      apply TODO.
    - intros v c.
      simpl.
      apply TODO.
  Defined.

  Definition acti_to_acat_data
    : psfunctor_data ACTI ACAT.
  Proof.
    use make_psfunctor_data.
    - exact acti_to_acat_on_ob.
    - exact (λ a1 a2 f, acti_to_acat_on_mor f).
    - intros a1 a2 f g α.
      exists (pr1 α).
      intros v a.
      exact (toforallpaths _ _ _ (base_paths _ _ (pr2 α v)) a).
    - intro a.
      use tpair.
      + exists (λ c, identity c).
        intro ; intros ; exact (id_right _ @ ! id_left _).
      + intros v c.
        cbn.
        rewrite ! id_right.
        unfold identity_lineator_data.
        cbn.
        apply (! functor_id _ _).
    - intros a1 a2 a3 f g.
      use tpair.
      + exists (λ c, identity _).
        intro ; intros ; exact (id_right _ @ ! id_left _).
      + intros v c.
        cbn.
        unfold comp_lineator_data.
        cbn.

        rewrite ! id_right.
        rewrite ! id_left.
        cbn.
        rewrite (functor_id ((pr12 a3) v)).
        rewrite id_left.
        apply idpath.
  Defined.

  Definition acti_to_acat_laws
    : psfunctor_laws acti_to_acat_data.
  Proof.
    repeat split ; (intro ; intros ; use total2_paths_f ;
                    [try (apply idpath) ; try (use nat_trans_eq ; [apply homset_property | intro ; cbn])
                    | apply proofirrelevance ;
                      repeat (apply impred_isaprop ; intro) ; apply homset_property
                   ]).

    - rewrite ! id_right ; apply (! functor_id _ _).
    - rewrite ! id_right ; apply idpath.
    - rewrite ! id_right ; rewrite (! functor_id _ _) ; rewrite id_left ; apply idpath.
    - rewrite id_left ; apply (! id_right _).
    - rewrite id_left ; apply (! id_right _).
  Qed.


  Definition acti_to_acat_invertible_cells
    : invertible_cells acti_to_acat_data.
  Proof.
    use tpair.
    - intro.
      use tpair.
      + use tpair.
        * apply nat_trans_id.
        * intro ; intro.
          cbn.
          rewrite ! id_right.
          apply (! functor_id _ _).
      + use tpair.
        * use total2_paths_f.
          -- use nat_trans_eq.
             { apply homset_property. }
             intro.
             apply id_right.
          -- apply proofirrelevance.
             repeat (apply impred_isaprop ; intro).
             apply homset_property.
        * use total2_paths_f.
          -- use nat_trans_eq.
             { apply homset_property. }
             intro.
             apply id_right.
          -- apply proofirrelevance.
             repeat (apply impred_isaprop ; intro).
             apply homset_property.
    - intro ; intros.
      use tpair.
      + use tpair.
        * apply nat_trans_id.
        * intro ; intro.
          cbn.
          unfold ActionBasedStrongFunctorsWhiskeredMonoidal.parameterized_distributivity_bicat_nat_funclass.
          unfold comp_lineator_data.
          cbn.
          rewrite ! id_right.
          rewrite ! id_left.
          rewrite (functor_id  (((pr12 c) v))).
          rewrite id_left.
          apply idpath.
      + use tpair ;
          (use total2_paths_f
           ; [
              use nat_trans_eq ;
              [ apply homset_property
              | intro ; apply id_right ]
            |
              apply proofirrelevance ;
              repeat (apply impred_isaprop ; intro) ;
              apply homset_property
          ]).
  Qed.

  Definition acti_to_acat
    : psfunctor ACTI ACAT.
  Proof.
    use make_psfunctor.
    - exact acti_to_acat_data.
    - exact acti_to_acat_laws.
    - exact acti_to_acat_invertible_cells.
  Defined.

End FromActionInCatToActegories.

Section ActionInCatEquivActegories.

  Require Import UniMath.Bicategories.Transformations.PseudoTransformation.

  Definition acti_to_acat_unit_data_on_ob (a : ACTI)
    : ACTI ⟦Composition.comp_psfunctor acat_to_acti acti_to_acat a, Identity.id_psfunctor ACTI a⟧.
  Proof.
    exists (identity _).
    use tpair.
      + use make_nat_trans.
        * intro v.
          exists (λ c, identity _).
          intros c1 c2 f.
          abstract (
              simpl ;
              rewrite id_left ;
              apply id_right).
        * intros v w f.
          use nat_trans_eq.
          { apply homset_property. }
          intro c.
          abstract (
              cbn ;
              do 2 rewrite id_right ;
              rewrite id_left ;
              rewrite (functor_id  ((pr12 a) v)) ;
              apply id_left).
      + use tpair.
        * use nat_trans_eq.
          { apply homset_property. }
          intro c.
          abstract (
              cbn ;
              rewrite id_right ;
              rewrite ! id_left ;
              apply idpath).
        * intro ; intro.
          use nat_trans_eq.
          { apply homset_property. }
          intro c.
          abstract (
              cbn ;
              rewrite ! id_left ;
              rewrite ! id_right ;
              rewrite (functor_id ((pr12 a) w)) ;
              apply (! id_left _)).
  Defined.

  Definition acti_to_acat_unit_data
    :  pstrans_data (Composition.comp_psfunctor acat_to_acti acti_to_acat) (Identity.id_psfunctor ACTI).
  Proof.
    use make_pstrans_data.
    - exact (λ a, acti_to_acat_unit_data_on_ob a).
    - intros a1 a2 f.
      use tpair.
      + use tpair.
        * exists (λ c, identity _).
          intros c1 c2 g.
          abstract (
              simpl ;
              rewrite id_left ;
              apply id_right
            ).
        * intro.
          use nat_trans_eq.
          { apply homset_property. }
          intro.
          abstract (
              cbn ;
              rewrite ! id_left ;
              rewrite ! id_right ;
              unfold ActionBasedStrongFunctorsWhiskeredMonoidal.parameterized_distributivity_bicat_nat_funclass ;
              rewrite (functor_id (pr1 f)) ;
              rewrite (functor_id ((pr12 a2) v)) ;
              rewrite id_left ;
              apply id_right
            ).
      +  use tpair.
         * use tpair.
           -- exists (λ c, identity _).
              intros c1 c2 g.
              simpl.
              rewrite id_left.
              apply id_right.
           -- intro.
              use nat_trans_eq.
              { apply homset_property. }
              intro.
              abstract (
                  simpl ;
                  rewrite ! id_left ;
                  rewrite ! id_right ;
                  rewrite (functor_id  ((pr12 a2) v)) ;
                  rewrite (functor_id (pr1 f)) ;
                  rewrite id_left ;
                  apply (! id_right _)
                ).
         * use tpair.
           -- use total2_paths_f.
              ++ apply nat_trans_eq.
                 { apply homset_property. }
                 intro.
                 simpl.
                 apply id_right.
              ++ apply proofirrelevance.
                 unfold disp_2cells.
                 apply impred_isaprop ; intro.
                 apply cellset_property.
           -- use total2_paths_f.
              ++ apply nat_trans_eq.
                 { apply homset_property. }
                 intro.
                 simpl.
                 apply id_right.
              ++ apply proofirrelevance.
                 unfold disp_2cells.
                 apply impred_isaprop ; intro.
                 apply cellset_property.
  Defined.

  Lemma acti_to_acat_unit_is_pstrans
    : is_pstrans acti_to_acat_unit_data.
  Proof.
    repeat split ;
      (intro ; intros
       ; use total2_paths_f ;
             [
               apply nat_trans_eq ; [apply homset_property | intro ; intros ; simpl ]
             |
               apply proofirrelevance ; apply impred_isaprop ; intro ; apply cellset_property
             ]
      ).
    - rewrite id_left ; apply id_right.
    - rewrite id_left ; apply (! id_left _).
    - rewrite ! id_left ; rewrite ! id_right ; apply (! functor_id _ _).
  Qed.

  Definition acti_to_acat_unit
    :  pstrans (Composition.comp_psfunctor acat_to_acti acti_to_acat) (Identity.id_psfunctor ACTI).
  Proof.
    use make_pstrans.
    - exact acti_to_acat_unit_data.
    - exact acti_to_acat_unit_is_pstrans.
  Defined.

  Definition acti_to_acat_counit_data_on_ob (a : ACAT)
    : ACAT ⟦Composition.comp_psfunctor acti_to_acat acat_to_acti a, Identity.id_psfunctor ACAT a⟧.
  Proof.
    exists (identity _).
    use tpair.
    + exists (λ _ _, identity _).
      abstract (
          simpl ;
          repeat split ; (intro ; intros ; try (rewrite id_right ; rewrite id_left ; apply idpath)) ;
          [
            rewrite id_left ;
            rewrite id_right ;
            rewrite bifunctor_leftid ;
            apply (! id_right _)
          |
            rewrite id_left ; apply idpath ]).
    + intro ; intro ; apply is_z_isomorphism_identity.
  Defined.

  Definition acti_to_acat_counit_data
    :  pstrans_data (Composition.comp_psfunctor acti_to_acat acat_to_acti) (Identity.id_psfunctor ACAT).
  Proof.
    use make_pstrans_data.
    - exact (λ a, acti_to_acat_counit_data_on_ob a).
    - intros a1 a2 f.
      use tpair.
      + use tpair.
        * exists (λ c, identity _).
          intros c1 c2 g.
          abstract (
              simpl ;
              rewrite id_left ;
              apply id_right
            ).
        * abstract (
              intro ; intro ;
              simpl ;
              unfold comp_lineator_data ;
              simpl ;
              rewrite functor_id ;
              rewrite ! id_right ;
              rewrite bifunctor_leftid ;
              rewrite ! id_left ;
              apply idpath
            ).
      + use tpair.
        * use tpair.
           -- exists (λ c, identity _).
              abstract (
                  intros c1 c2 g ;
                  simpl ;
                  rewrite id_left ;
                  apply id_right
                ).
           -- abstract (
                  intro ; intro ;
                  simpl ;
                  unfold comp_lineator_data ;
                  simpl ;
                  rewrite functor_id ;
                  rewrite ! id_right ;
                  rewrite bifunctor_leftid ;
                  rewrite ! id_left ;
                  apply idpath
                ).
        * use tpair ; use total2_paths_f.
          ++  use total2_paths_f.
              ** apply funextsec ; intro.
                 apply id_right.
              ** apply isaprop_is_nat_trans ; apply homset_property.
          ++ apply proofirrelevance.
             repeat (apply impred_isaprop ; intro).
             apply homset_property.
          ++ use nat_trans_eq.
             { apply homset_property. }
             intro ; simpl ; apply id_right.
          ++ apply proofirrelevance ; repeat (apply impred_isaprop ; intro) ; apply homset_property.
  Defined.

  Lemma acti_to_acat_counit_is_pstrans
    : is_pstrans acti_to_acat_counit_data.
  Proof.
    repeat split ;
      (intro ; intros
       ; use total2_paths_f ;
             [
               apply nat_trans_eq ; [apply homset_property | intro ; intros ; simpl ]
             |
               apply proofirrelevance ; repeat (apply impred_isaprop ; intro) ; apply homset_property
             ]
      ).

    - rewrite id_left ; apply id_right.
    - rewrite id_left ; apply (! id_left _).
    - rewrite ! id_left ; rewrite ! id_right ; apply (! functor_id _ _).
  Qed.

  Definition acti_to_acat_counit
    :  pstrans (Composition.comp_psfunctor acti_to_acat acat_to_acti) (Identity.id_psfunctor ACAT).
  Proof.
    use make_pstrans.
    - exact acti_to_acat_counit_data.
    - exact acti_to_acat_counit_is_pstrans.
  Defined.

  Definition acti_biequiv_unit_counit_acat
    : is_biequivalence_unit_counit acti_to_acat acat_to_acti.
  Proof.
    exists acti_to_acat_unit.
    exact acti_to_acat_counit.
  Defined.

  Definition ps_base_ACTI
    :  Base.ps_base ACTI ACTI ⟦ pr111 (Identity.id_psfunctor ACTI),
  pr111 (Composition.comp_psfunctor acat_to_acti acti_to_acat) ⟧.
  Proof.
    intro.
    exists (functor_identity _).
    use tpair.
    + use make_nat_trans.
      * intro.
        exists (λ _, identity _).
        abstract (
            intro ; intros ;
            rewrite id_left ;
            apply id_right
          ).
      * intro ; intros.
        use total2_paths_f.
        -- abstract (
               apply funextsec ; intro ;
               cbn ;
               rewrite (functor_id ((pr12 x) x0)) ;
               rewrite ! id_left ;
               apply idpath
             ).
        -- apply isaprop_is_nat_trans ; apply homset_property.
      + use tpair.
        * use nat_trans_eq.
          { apply homset_property. }
          abstract (
              intro ;
              cbn ;
              rewrite ! id_left ;
              apply id_right
            ).
        * intro ; intro.
          use nat_trans_eq.
          { apply homset_property. }
          abstract (
              intro ;
              cbn ;
              rewrite ! id_left ;
              rewrite ! id_right ;
              rewrite (functor_id ((pr12 x) w)) ;
              apply (! id_left _)
            ).
  Defined.

  Definition ps_base_ACAT
    :  Base.ps_base ACAT ACAT ⟦ pr111 (Identity.id_psfunctor ACAT),
                                pr111 (Composition.comp_psfunctor acti_to_acat acat_to_acti) ⟧.
  Proof.
    intro.
    exists (functor_identity _).
    repeat (use tpair).
    - exact (λ _ _, identity _).
    - abstract (
            intro ; intros ;
            rewrite id_left ;
            apply id_right
        ).
    - abstract (
            intro ; intros ;
            rewrite id_left ;
            apply id_right
        ).
    - abstract (
          intro ; intros ;
          cbn ;
          rewrite bifunctor_leftid ;
          rewrite ! id_left ;
          rewrite ! id_right ;
          apply idpath
        ).
    - abstract (intro ; apply id_left).
    - intro ; intro ; apply is_z_isomorphism_identity.
  Defined.

  Definition ACAT_invertible_2cell {a1 a2 : ACAT} (f : ACAT⟦a1,a2⟧)
    : invertible_2cell (ps_base_ACAT a1 · acti_to_acat_on_mor (acat_to_acti_on_mor f)) (f · ps_base_ACAT a2).
  Proof.
    repeat (use tpair).
    - exact (λ _, identity _).
    - abstract (
            intro ; intros ;
            cbn ;
            rewrite id_left ;
            apply id_right
        ).
    - abstract (
          intro ; intro ;
          cbn ;
          unfold comp_lineator_data ;
          simpl ;
          rewrite bifunctor_leftid ;
          rewrite ! id_left ;
          rewrite functor_id ;
          rewrite id_right ;
          apply id_right
        ).
    - exact (λ _, identity _).
    - abstract (
            intro ; intros ;
            cbn ;
            rewrite id_left ;
            apply id_right
        ).
    - abstract (
          intro ; intro ;
          cbn ;
          unfold comp_lineator_data ;
          simpl ;
          rewrite bifunctor_leftid ;
          rewrite ! id_left ;
          rewrite functor_id ;
          apply idpath
        ).
    - abstract (
          use total2_paths_f ;
          [ use nat_trans_eq ;
            [ apply homset_property |
              intro ;
              simpl ;
              apply id_right
            ]
          |
           apply proofirrelevance ;
           repeat (apply impred_isaprop ; intro) ;
           apply homset_property
        ]).
    - abstract (
          use total2_paths_f ;
          [ use nat_trans_eq ;
            [ apply homset_property |
              intro ;
              simpl ;
              apply id_right
            ]
          |
           apply proofirrelevance ;
           repeat (apply impred_isaprop ; intro) ;
           apply homset_property
          ]).
  Defined.

  Definition ACTI_invertible_2cell {a1 a2 : ACTI} (f : ACTI⟦a1,a2⟧)
    :   invertible_2cell (ps_base_ACTI a1 · acat_to_acti_on_mor (acti_to_acat_on_mor f)) (f · ps_base_ACTI a2).
  Proof.
    use tpair.
    - use tpair.
      + exists (λ _, identity _).
        abstract (
            intro ; intros ;
            cbn ;
            rewrite id_left ;
            apply id_right
          ).
      + intro.
        use nat_trans_eq.
        { apply homset_property. }
        abstract (
            intro ;
            cbn ;
            rewrite (functor_id (pr1 f)) ;
            rewrite ! id_left ;
            rewrite ! id_right ;
            rewrite (functor_id ((pr12 a2) v)) ;
            apply (! id_left _)
          ).
    - use tpair.
      + use tpair.
        * exists (λ _, identity _).
          abstract (
              intro ; intros ;
              rewrite id_left ;
              apply id_right
            ).
        * intro.
          use nat_trans_eq.
          { apply homset_property. }
          abstract (
              intro ;
              cbn ;
              rewrite (functor_id (pr1 f)) ;
              rewrite ! id_left ;
              rewrite ! id_right ;
              rewrite (functor_id ((pr12 a2) v)) ;
              apply (! id_left _)
            ).
      + abstract (
            use tpair ;
            (use total2_paths_f ;
             [
               use nat_trans_eq ;
               [ apply homset_property
               | intro ; apply id_left
               ]
             |
               apply proofirrelevance ;
               apply impred_isaprop ; intro ;
               apply cellset_property
            ])).
  Defined.

  Definition ps_functor_ACTI
    : psfunctor_bicat ACTI ACTI ⟦ Identity.id_psfunctor ACTI,
                                  Composition.comp_psfunctor acat_to_acti acti_to_acat ⟧.
  Proof.
    refine (_ ,, tt).
    use tpair.
    - exists ps_base_ACTI.
      exact (λ a1 a2 f, ACTI_invertible_2cell f).
    - repeat (use tpair) ;
        (
          intro ; intros ; use total2_paths_f ;
          [

            use nat_trans_eq ;
            [ apply homset_property | intro ; intros ; simpl ]

          |
            use proofirrelevance ;
                apply impred_isaprop ;
                intro ;
                apply cellset_property

              ]
        ).
      + abstract (rewrite id_left ; apply id_right).
      + abstract (apply idpath).
      + abstract (rewrite ! id_left ;
                  rewrite ! id_right ;
                  apply (! functor_id (pr1 g) _)
                 ).
  Defined.

  Definition ps_functor_ACAT
    :  psfunctor_bicat ACAT ACAT ⟦ Identity.id_psfunctor ACAT,
  Composition.comp_psfunctor acti_to_acat acat_to_acti ⟧.
  Proof.
    refine (_ ,, tt).
    use tpair.
    - exists ps_base_ACAT.
      exact (λ a1 a2 f, ACAT_invertible_2cell f).
    - repeat (use tpair) ;
        (
          intro ; intros ; use total2_paths_f ;
          [

            use nat_trans_eq ;
            [ apply homset_property | intro ; intros ; simpl ]

          |
            use proofirrelevance ;
                repeat (apply impred_isaprop ;
                intro) ;
                apply homset_property

              ]
        ).
      + abstract (rewrite id_left ; apply id_right).
      + abstract (apply idpath).
      + abstract (rewrite ! id_left ;
                  rewrite ! id_right ;
                  apply (! functor_id (pr1 g) _)
                 ).
  Defined.


  Definition unit_left_adjoint_data
    :  Adjunctions.left_adjoint_data acti_to_acat_unit.
  Proof.
    exists ps_functor_ACTI.
    use tpair ; refine (_ ,, tt).

    - use tpair.
      + use tpair.
        * intro. use tpair.
          -- exists (λ _, identity _).
             abstract (
                 intro ; intros ;
                 simpl ;
                 rewrite id_left ;
                 rewrite id_right ;
                 apply idpath
               ).
          -- intro ; intros.
             use nat_trans_eq.
             { apply homset_property. }
             abstract (
                 intro ;
                 cbn ;
                 rewrite ! id_left ;
                 rewrite id_right ;
                 apply (! functor_id _ _)
               ).
        * intro ; intros.
          use total2_paths_f.
          -- use nat_trans_eq.
             { apply homset_property. }
             abstract (
                 intro ;
                 simpl ;
                 rewrite ! id_right ;
                 apply (! functor_id (pr1 f) _)
               ).
          -- use proofirrelevance ;
                       apply impred_isaprop ; intro ;
                       apply cellset_property.
      + exact (tt,,(tt,,tt)).

    - use tpair.
      + use tpair.
        * intro.
          use tpair.
          -- exists (λ _, identity _).
             abstract (
                 intro ; intros ;
                 rewrite id_left ;
                 apply id_right
               ).
          -- intro ; intros.
             use nat_trans_eq.
             { apply homset_property. }
             abstract (
                 intro ; simpl ;
                 rewrite ! id_left ;
                 rewrite id_right ;
                 apply (! functor_id _ _)
               ).
        * intro ; intros.
          use total2_paths_f.
          -- use nat_trans_eq.
             { apply homset_property. }
             abstract (
                 intro ;
                 simpl ;
                 rewrite (functor_id (pr1 f) _) ;
                 rewrite ! id_right ;
                 apply idpath
               ).
          -- abstract (
                 use proofirrelevance ;
                 apply impred_isaprop ; intro ;
                 apply cellset_property
               ).
      + exact (tt,, (tt,,tt)).
  Defined.

  Definition counit_left_adjoint_data
    :  Adjunctions.left_adjoint_data acti_to_acat_counit.
  Proof.
    exists ps_functor_ACAT.
    use tpair ; refine (_ ,, tt).

    - use tpair.
      + use tpair.
        * intro.
          use tpair.
          -- exists (λ _, identity _).
             abstract (
                 intro ; intros ;
                 simpl ;
                 rewrite id_left ;
                 rewrite id_right ;
                 apply idpath
               ).
          -- abstract (
                 intro ; intros ;
                 cbn ;
                 rewrite bifunctor_leftid ;
                 rewrite ! id_left ;
                 apply (! id_right _)
               ).
        * intro ; intros.
          use total2_paths_f.
          -- use nat_trans_eq.
             { apply homset_property. }
             abstract (
                 intro ;
                 cbn ;
                 rewrite ! id_left ;
                 rewrite id_right ;
                 apply (! functor_id _ _)
               ).
          -- use proofirrelevance ;
               repeat (apply impred_isaprop ; intro) ;
               apply homset_property.

      + exact (tt,,(tt,,tt)).
    - use tpair.
      + use tpair.
        * intro.
          use tpair.
          -- exists (λ _, identity _).
             abstract (
                 intro ; intros ;
                 rewrite id_left ;
                 apply id_right
               ).
          -- abstract (
                 intro ; intros ;
                 simpl ;
                 rewrite bifunctor_leftid ;
                 apply id_right
               ).
        * intro ; intros.
          use total2_paths_f.
          -- use nat_trans_eq.
             { apply homset_property. }
             abstract (
                 intro ;
                 cbn ;
                 rewrite ! id_left ;
                 rewrite id_right ;
                 apply (! functor_id _ _)
               ).
          -- use proofirrelevance ;
               repeat (apply impred_isaprop ; intro) ;
               apply homset_property.

      + exact (tt,,(tt,,tt)).
  Defined.

  Lemma unit_left_adjoints_axioms
    :  Adjunctions.left_adjoint_axioms unit_left_adjoint_data.
  Proof.
    use tpair.
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (
                    intro ;
                    simpl ;
                    rewrite ! id_right ;
                    apply idpath
                  ).
             ++ apply proofirrelevance.
                apply impred_isaprop ; intro.
                apply cellset_property.
          -- apply proofirrelevance.
             repeat (apply impred_isaprop ; intro).
             apply cellset_property.
        * use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit).
      + apply proofirrelevance.
        apply isapropunit.
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (
                    intro ;
                    simpl ;
                    rewrite ! id_right ;
                    apply idpath
                  ).
             ++ apply proofirrelevance.
                apply impred_isaprop ; intro.
                apply cellset_property.
          -- apply proofirrelevance.
             repeat (apply impred_isaprop ; intro).
             apply cellset_property.
        * use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit).
      + apply proofirrelevance.
        apply isapropunit.
  Qed.

  Lemma is_invertible_2cell_unit
    : is_invertible_2cell (Adjunctions.left_adjoint_unit unit_left_adjoint_data).
  Proof.
    repeat (use tpair) ; try (exact tt).
    - intro.
      use tpair.
      + exists (λ _, identity _).
        abstract (
            intro ; intros ;
            simpl ;
            rewrite id_left ;
            apply id_right
          ).
      + intro ; intros.
        use nat_trans_eq.
        { apply homset_property. }
        abstract (
            intro ;
            simpl ;
            rewrite ! id_left ;
            rewrite id_right ;
            apply (! functor_id _ _)
          ).
    - intro ; intros.
      use total2_paths_f.
      + use nat_trans_eq.
        { apply homset_property. }
        abstract (
            intro ;
            simpl ;
            rewrite ! id_left ;
            rewrite id_right ;
            apply (! functor_id _ _)
          ).
      + abstract (
            apply proofirrelevance ;
            apply impred_isaprop ; intro ;
            apply cellset_property
          ).
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (intro ; simpl ; apply id_right).
             ++ abstract (
                    apply proofirrelevance ;
                    apply impred_isaprop ; intro ;
                    apply cellset_property
                  ).
          -- abstract (
                    apply proofirrelevance ;
                    repeat (apply impred_isaprop ; intro) ;
                    apply cellset_property
               ).
        * use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit).
      + apply proofirrelevance ; apply isapropunit.
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (intro ; simpl ; apply id_right).
             ++ abstract (
                    apply proofirrelevance ;
                    apply impred_isaprop ; intro ;
                    apply cellset_property
                  ).
          -- abstract (
                    apply proofirrelevance ;
                    repeat (apply impred_isaprop ; intro) ;
                    apply cellset_property
               ).
        * use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit).
      + apply proofirrelevance ; apply isapropunit.
  Qed.

  Lemma is_invertible_2cell_counit
    : is_invertible_2cell (Adjunctions.left_adjoint_counit unit_left_adjoint_data).
  Proof.
    repeat (use tpair) ; try (exact tt).
    - intro.
      use tpair.
      + exists (λ _, identity _).
        abstract (
            intro ; intros ;
            simpl ;
            rewrite id_left ;
            apply id_right
          ).
      + intro ; intros.
        use nat_trans_eq.
        { apply homset_property. }
        abstract (
            intro ;
            simpl ;
            rewrite ! id_left ;
            rewrite id_right ;
            apply (! functor_id _ _)
          ).
    - intro ; intros.
      use total2_paths_f.
      + use nat_trans_eq.
        { apply homset_property. }
        abstract (
            intro ;
            simpl ;
            rewrite ! id_left ;
            rewrite id_right ;
            apply (! functor_id _ _)
          ).
      + abstract (
            apply proofirrelevance ;
            apply impred_isaprop ; intro ;
            apply cellset_property
          ).
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (intro ; simpl ; apply id_right).
             ++ abstract (
                    apply proofirrelevance ;
                    apply impred_isaprop ; intro ;
                    apply cellset_property
                  ).
          -- abstract (
                    apply proofirrelevance ;
                    repeat (apply impred_isaprop ; intro) ;
                    apply cellset_property
               ).
        * use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit).
      + apply proofirrelevance ; apply isapropunit.
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (intro ; simpl ; apply id_right).
             ++ abstract (
                    apply proofirrelevance ;
                    apply impred_isaprop ; intro ;
                    apply cellset_property
                  ).
          -- abstract (
                    apply proofirrelevance ;
                    repeat (apply impred_isaprop ; intro) ;
                    apply cellset_property
               ).
        * use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit).
      + apply proofirrelevance ; apply isapropunit.
  Qed.

  Definition prebicat_cells_ACAT (a : ACAT)
    :  prebicat_cells ACAT ((pr111 (identity (Identity.id_psfunctor ACAT))) a)
                      ((pr111 (Adjunctions.left_adjoint_right_adjoint counit_left_adjoint_data · acti_to_acat_counit)) a).
  Proof.
    use tpair.
      + exists (λ _, identity _).
        abstract (
            intro ; intros ;
            simpl ;
            rewrite id_left ;
            apply id_right
          ).
      + abstract (
            intro ; intros ;
            simpl ;
            rewrite bifunctor_leftid ;
            apply (! id_left _)
          ).
  Defined.


  Lemma is_invertible_2cell_counit'
    : is_invertible_2cell (Adjunctions.left_adjoint_counit counit_left_adjoint_data).
  Proof.
    repeat (use tpair) ; try (exact tt).
    - exact (λ _, prebicat_cells_ACAT _).

    - intro ; intros.
      use total2_paths_f.
      + use nat_trans_eq.
        { apply homset_property. }
        abstract (
            intro ;
            simpl ;
            rewrite ! id_left ;
            rewrite id_right ;
            apply (! functor_id _ _)
          ).
      + abstract (
            apply proofirrelevance ;
            repeat (apply impred_isaprop ; intro) ;
            apply homset_property
          ).
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (intro ; simpl ; apply id_right).
             ++ abstract (
                    apply proofirrelevance ;
                    repeat (apply impred_isaprop ; intro) ;
                    apply homset_property
                  ).
          -- abstract (
                 apply proofirrelevance ;
                 repeat (apply impred_isaprop ; intro) ;
                 apply cellset_property
               ).
        * abstract (use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit)).
      + abstract (apply isapropunit).
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (intro ; simpl ; apply id_right).
             ++  abstract (
                     apply proofirrelevance ;
                     repeat (apply impred_isaprop ; intro) ;
                     apply homset_property
                   ).
          -- abstract (
                 apply proofirrelevance ;
                 repeat (apply impred_isaprop ; intro) ;
                 apply cellset_property
               ).
        * abstract (use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit)).
      + abstract (apply isapropunit).
  Qed.

  Lemma counit_left_adjoints_axioms
    :  Adjunctions.left_adjoint_axioms counit_left_adjoint_data.
  Proof.
    use tpair.
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (
                    intro ;
                    simpl ;
                    rewrite ! id_right ;
                    apply idpath
                  ).
             ++ abstract (
                    apply proofirrelevance ;
                    repeat (apply impred_isaprop ; intro) ;
                    apply homset_property).
          -- abstract (
                 apply proofirrelevance ;
                 repeat (apply impred_isaprop ; intro) ;
                 apply cellset_property
               ).
        * abstract (use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit)).
      + abstract (apply isapropunit).
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (
                    intro ;
                    simpl ;
                    rewrite ! id_right ;
                    apply idpath
                  ).
             ++ abstract (
                    apply proofirrelevance ;
                    repeat (apply impred_isaprop ; intro) ;
                    apply homset_property
                  ).
          -- abstract (
                 apply proofirrelevance ;
                 repeat (apply impred_isaprop ; intro) ;
                 apply cellset_property
               ).
        * abstract (use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit)).
      + abstract (apply isapropunit).
  Qed.

  Lemma is_invertible_2cell_unit'
    :  is_invertible_2cell (Adjunctions.left_adjoint_unit counit_left_adjoint_data).
  Proof.
    repeat (use tpair) ; try (exact tt).
    - intro.
      use tpair.
      + exists (λ _, identity _).
        abstract (
            intro ; intros ;
            simpl ;
            rewrite id_left ;
            apply id_right
          ).
      + abstract (
            intro ; intros ;
            simpl ;
            unfold comp_lineator_data ;
            unfold identity_lineator_data ;
            cbn ;
            rewrite bifunctor_leftid ;
            apply id_right
          ).
    - intro ; intros.
      use total2_paths_f.
      + use nat_trans_eq.
        { apply homset_property. }
        abstract (
            intro ;
            simpl ;
            rewrite ! id_left ;
            rewrite id_right ;
            apply (! functor_id _ _)
          ).
      + abstract (
            apply proofirrelevance ;
            repeat (apply impred_isaprop ; intro) ;
            apply homset_property
          ).
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (intro ; simpl ; apply id_right).
             ++ abstract (
                    apply proofirrelevance ;
                    repeat (apply impred_isaprop ; intro) ;
                    apply homset_property
                  ).
          -- abstract (
                    apply proofirrelevance ;
                    repeat (apply impred_isaprop ; intro) ;
                    apply cellset_property
               ).
        * abstract (use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit)).
      + abstract (apply proofirrelevance ; apply isapropunit).
    - use total2_paths_f.
      + use total2_paths_f.
        * use total2_paths_f.
          -- apply funextsec ; intro.
             use total2_paths_f.
             ++ use nat_trans_eq.
                { apply homset_property. }
                abstract (intro ; simpl ; apply id_right).
             ++ abstract (
                    apply proofirrelevance ;
                    repeat (apply impred_isaprop ; intro) ;
                    apply homset_property
                  ).
          -- abstract (
                    apply proofirrelevance ;
                    repeat (apply impred_isaprop ; intro) ;
                    apply cellset_property
               ).
        * abstract (use total2_paths_f ;
            (apply proofirrelevance ; try (apply isapropdirprod) ; apply isapropunit)).
      + abstract (apply isapropunit).
  Qed.

  Lemma unit_left_adjoint_equiv_axiom
    :  Adjunctions.left_equivalence_axioms unit_left_adjoint_data.
  Proof.
    exists is_invertible_2cell_unit.
    exact is_invertible_2cell_counit.
  Qed.

  Lemma counit_left_adjoint_equiv_axiom
    :  Adjunctions.left_equivalence_axioms counit_left_adjoint_data.
  Proof.
    exists is_invertible_2cell_unit'.
    exact is_invertible_2cell_counit'.
  Qed.

  Definition unit_left_adjoint_equivalence
    :  Adjunctions.left_adjoint_equivalence (unit_of_is_biequivalence acti_biequiv_unit_counit_acat).
  Proof.
    exists unit_left_adjoint_data.
    exists unit_left_adjoints_axioms.
    exact unit_left_adjoint_equiv_axiom.
  Defined.

  Definition counit_left_adjoint_equivalence
    :  Adjunctions.left_adjoint_equivalence (counit_of_is_biequivalence acti_biequiv_unit_counit_acat).
  Proof.
    exists counit_left_adjoint_data.
    exists counit_left_adjoints_axioms.
    exact counit_left_adjoint_equiv_axiom.
  Defined.

  Definition acti_biequiv_adj_acat
    : is_biequivalence_adjoints acti_biequiv_unit_counit_acat.
  Proof.
    exists unit_left_adjoint_equivalence.
    exact counit_left_adjoint_equivalence.
  Defined.

  Definition acti_is_biequiv_acat
    : is_biequivalence acti_to_acat.
  Proof.
    exists acat_to_acti.
    exists acti_biequiv_unit_counit_acat.
    exact acti_biequiv_adj_acat.
  Defined.

  Definition acti_biequiv_acat
    : biequivalence ACTI ACAT.
  Proof.
    exists (acti_to_acat).
    exact acti_is_biequiv_acat.
  Defined.

End ActionInCatEquivActegories.
