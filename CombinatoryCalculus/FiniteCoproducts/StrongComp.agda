module FiniteCoproducts.StrongComp where
open import FiniteCoproducts.Utils
open import FiniteCoproducts.Syntax
open import FiniteCoproducts.BigStep

-- Strong Computability
SCN : ∀ {σ} → Nf σ → Set
SCN {ι}     n = ⊤
SCN {σ ⇒ τ} f = ∀ a → SCN a → 
  Σ (Nf τ) λ n →  (f ∙ⁿ a ⇓ n) × SCN n × (⌜ f ⌝ ∙ ⌜ a ⌝ ≈ ⌜ n ⌝)
SCN {Zero}     n = ⊥
SCN {σ + τ} (inlⁿ¹ x) = SCN x
SCN {σ + τ} (inrⁿ¹ x) = SCN x

SCC : ∀ {σ τ ρ}(l : Nf (σ ⇒ ρ))(r : Nf (τ ⇒ ρ))(c : Nf (σ + τ)) →
      SCN l → SCN r → SCN c → 
      Σ (Nf ρ) 
         λ n → (Cⁿ² l r ∙ⁿ c ⇓ n) × SCN n × (C ∙ ⌜ l ⌝ ∙ ⌜ r ⌝ ∙ ⌜ c ⌝ ≈ ⌜ n ⌝)
SCC l r (inlⁿ¹ x) sl sr sx = 
  proj₁ lx
    , (rCⁿ²ˡ (π₀ (proj₂ lx)) , π₁ (proj₂ lx) , ≈trans Cl (π₂ (proj₂ lx))) 
  where lx = sl x sx
SCC l r (inrⁿ¹ x) sl sr sx = 
  proj₁ rx
    , (rCⁿ²ʳ (π₀ (proj₂ rx)) , π₁ (proj₂ rx) , ≈trans Cr (π₂ (proj₂ rx))) 
  where rx = sr x sx

ZE : ⊥ → {X : Set} → X
ZE ()

prop1 : ∀ {σ} → (n : Nf σ) → SCN n
prop1 Kⁿ        = λ x sx → Kⁿ¹ x ,
                               (rKⁿ , (λ y sy → x , (rKⁿ¹ , sx , ≈K)) , ≈refl)
prop1 (Kⁿ¹ x)   = λ y sy → x , (rKⁿ¹ , prop1 x , ≈K) 
prop1 Sⁿ        = λ x sx → Sⁿ¹ x ,
                               (rSⁿ ,
                                   (λ y sy → Sⁿ² x y ,
                                                 (rSⁿ¹ ,
                                                     (λ z sz → 
  let pxz = sx z sz
      pyz = sy z sz
      pxzyz = π₁ (proj₂ pxz) (proj₁ pyz) (π₁ (proj₂ pyz)) 
  in proj₁ pxzyz , 
          (rSⁿ² (π₀ (proj₂ pxz)) (π₀ (proj₂ pyz)) (π₀ (proj₂ pxzyz)) ,
              π₁ (proj₂ pxzyz) ,
              ≈trans ≈S 
                     (≈trans (≈∙-cong (π₂ (proj₂ pxz)) (π₂ (proj₂ pyz)))
                            (π₂ (proj₂ pxzyz))))) , ≈refl)) ,
  ≈refl)
prop1 (Sⁿ¹ x)   = λ y sy → Sⁿ² x y , (rSⁿ¹ , (λ z sz → 
  let sx = prop1 x
      pxz = sx z sz
      pyz = sy z sz
      pxzyz = π₁ (proj₂ pxz) (proj₁ pyz) (π₁ (proj₂ pyz)) 
  in proj₁ pxzyz ,
          (rSⁿ² (π₀ (proj₂ pxz)) (π₀ (proj₂ pyz)) (π₀ (proj₂ pxzyz)) ,
              π₁ (proj₂ pxzyz) ,
              ≈trans ≈S 
                     (≈trans (≈∙-cong (π₂ (proj₂ pxz)) (π₂ (proj₂ pyz)))
                            (π₂ (proj₂ pxzyz))))) ,
  ≈refl)  
prop1 (Sⁿ² x y) = λ z sz →
  let sx = prop1 x
      sy = prop1 y
      pxz = sx z sz
      pyz = sy z sz
      pxzyz = π₁ (proj₂ pxz) (proj₁ pyz) (π₁ (proj₂ pyz)) 
  in proj₁ pxzyz ,
          (rSⁿ² (π₀ (proj₂ pxz)) (π₀ (proj₂ pyz)) (π₀ (proj₂ pxzyz)) ,
              π₁ (proj₂ pxzyz) ,
              ≈trans ≈S 
                     (≈trans (≈∙-cong (π₂ (proj₂ pxz)) (π₂ (proj₂ pyz)))
                            (π₂ (proj₂ pxzyz))))
prop1 NEⁿ = λ z sz → ZE sz 
prop1 (inlⁿ¹ x)  = prop1 x 
prop1 (inrⁿ¹ x)  = prop1 x 
prop1 inlⁿ = λ x sx → inlⁿ¹ x , rinl , sx , ≈refl
prop1 inrⁿ = λ x sx → inrⁿ¹ x , rinr , sx , ≈refl

prop1 Cⁿ        = λ l sl → 
  Cⁿ¹ l ,
      (rCⁿ ,
          (λ r sr → Cⁿ² l r , (rCⁿ¹ , (λ c sc → SCC l r c sl sr sc) , ≈refl)) ,
          ≈refl) 
prop1 (Cⁿ¹ l)   = λ r sr → 
  Cⁿ² l r , (rCⁿ¹ , (λ c sc → SCC l r c (prop1 l) sr sc) , ≈refl) 
prop1 (Cⁿ² l r) = λ c sc → SCC l r c (prop1 l) (prop1 r) sc 

SC : ∀ {σ} → Tm σ → Set
SC {σ} t = Σ (Nf σ) λ n → (t ⇓ n) × SCN n × (t ≈ ⌜ n ⌝)

prop2 : ∀ {σ} → (t : Tm σ) → SC t
prop2 K       = Kⁿ , rK , prop1 Kⁿ , ≈refl
prop2 S       = Sⁿ , rS , prop1 Sⁿ , ≈refl
prop2 (t ∙ u) with prop2 t          | prop2 u
prop2 (t ∙ u) | f , rf , sf , cf | a , ra , sa , ca with sf a sa
prop2 (t ∙ u) | f , rf , sf , cf | a , ra , sa , ca | v , rv , sv , cv
  = v , (r∙ rf ra rv , sv , ≈trans (≈∙-cong cf ca) cv)
prop2 NE      = NEⁿ , rNE , (λ z sz → ZE sz) , ≈refl 
prop2 inl = inlⁿ , rinl , (λ x sx → inlⁿ¹ x , rinl , sx , ≈refl) , ≈refl
prop2 inr = inrⁿ , rinr , (λ x sx → inrⁿ¹ x , rinr , sx , ≈refl) , ≈refl
prop2 C       = 
  Cⁿ ,
      rC ,
          (λ l sl → Cⁿ¹ l ,
                        (rCⁿ ,
                            (λ r sr → Cⁿ² l r ,
                                          (rCⁿ¹ ,
                                              (λ c sc → SCC l r c sl sr sc) ,
                                              ≈refl)) ,
                            ≈refl)) ,
         ≈refl
