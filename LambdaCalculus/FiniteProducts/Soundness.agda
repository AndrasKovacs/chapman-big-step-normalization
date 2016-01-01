module FiniteProducts.Soundness where
open import FiniteProducts.Utils
open import FiniteProducts.Syntax
open import FiniteProducts.OPE
open import FiniteProducts.OPELemmas
open import FiniteProducts.OPERecursive
open import FiniteProducts.RecursiveNormaliser
open import FiniteProducts.Conversion
open import FiniteProducts.StrongConvertibility
open import FiniteProducts.IdentityEnvironment
mutual
  idext : ∀ {Γ Δ σ}(t : Tm Δ σ){vs vs' : Env Γ Δ} → vs ∼ˢ vs' →
          eval t vs ∼ eval t vs'
  idext top              (∼<< p q) = q 
  idext (t [ ts ])       p         = idext t (idextˢ ts p)
  idext (λt t)            p         = λ f p' → idext t (∼<< (∼ˢmap f p) p')   
  idext (t $ u){vs}{vs'} p         = 
    helper (sym (oidvmap (eval t vs))) 
           (sym (oidvmap (eval t vs'))) 
           (idext t p oid (idext u p)) 
  idext void             p         = tt
  idext < t , u >        p         = idext t p , idext u p
  idext (fst t)          p         = proj₁ (idext t p) 
  idext (snd t)          p         = proj₂ (idext t p) 

  idextˢ : ∀ {B Γ Δ}(ts : Sub Γ Δ){vs vs' : Env B Γ} → vs ∼ˢ vs' →
           evalˢ ts vs ∼ˢ evalˢ ts vs' 
  idextˢ (pop σ)   (∼<< p q) = p 
  idextˢ (ts < t)  p         = ∼<< (idextˢ ts p) (idext t p) 
  idextˢ id        p         = p 
  idextˢ (ts ○ us) p         = idextˢ ts (idextˢ us p)

mutual
  sfundthrm : ∀ {Γ Δ σ}{t t' : Tm Δ σ} → t ≈ t' →
              {vs vs' : Env Γ Δ} → vs ∼ˢ vs' → eval t vs ∼ eval t' vs'
  sfundthrm {t = t} ≈refl  q = idext t q
  sfundthrm (≈sym p)       q = sym∼ (sfundthrm p (sym∼ˢ q)) 
  sfundthrm (≈trans p p')  q = 
    trans∼ (sfundthrm p (trans∼ˢ q (sym∼ˢ q))) 
           (sfundthrm p' q)  
  sfundthrm (cong[] p p') q = sfundthrm p (sfundthrmˢ p' q) 
  sfundthrm (congλ p)     q = λ f p' → sfundthrm p (∼<< (∼ˢmap f q) p')  
  sfundthrm (cong$ {t = t}{t' = t'} p p')  q = 
    helper (sym (oidvmap (eval t  _)))
           (sym (oidvmap (eval t' _)))
           (sfundthrm p q oid (sfundthrm p' q)) 
  sfundthrm {t' = t'} top<          q = idext t' q 
  sfundthrm {t = t [ ts ] [ us ]} [][]          q = idext t (idextˢ ts (idextˢ us q))  
  sfundthrm {t' = t} []id          q = idext t q 
  sfundthrm (λ[] {t = t}{ts = ts}){vs}{vs'} q = λ f p → 
    helper' {t = t}
            (evˢmaplem f ts vs') 
            (idext t (∼<< (∼ˢmap f (idextˢ ts q)) p)) 
  sfundthrm ($[]{t = t}{u = u}{ts = ts}) q =
    helper (sym (oidvmap (eval t (evalˢ ts _))))
           (sym (oidvmap (eval t (evalˢ ts _))))
           (idext t (idextˢ ts q) oid (idext u (idextˢ ts q))) 
  sfundthrm (βλ {t = t}{u = u}) q = idext t (∼<< q (idext u q)) 
  sfundthrm (ηλ {t = t}){vs = vs}{vs' = vs'} q = λ f {a} {a'} p → 
    helper {f = vmap f (eval t vs)} 
           refl
           (evmaplem f t vs')
           (idext t q f p) 
  sfundthrm (cong<,> p q) r = sfundthrm p r , sfundthrm q r
  sfundthrm (congfst p)   q = proj₁ (sfundthrm p q) 
  sfundthrm (congsnd p)   q = proj₂ (sfundthrm p q) 
  sfundthrm void[]        p = tt
  sfundthrm (<,>[] {t = t}{u}{ts}) p =
    idext t (idextˢ ts p) , idext u (idextˢ ts p)
  sfundthrm (fst[] {t = t}{ts}) p = proj₁ (idext t (idextˢ ts p)) 
  sfundthrm (snd[] {t = t}{ts}) p = proj₂ (idext t (idextˢ ts p))
  sfundthrm {t' = t} βfst          p = idext t p 
  sfundthrm {t' = u} βsnd          p = idext u p 
  sfundthrm (η<,> {t = t}) p = idext t p 
  sfundthrm ηvoid         p = tt

  sfundthrmˢ : ∀ {B Γ Δ}{ts ts' : Sub Γ Δ} → ts ≃ˢ ts' →
               {vs vs' : Env B Γ} → vs ∼ˢ vs' → evalˢ ts vs ∼ˢ evalˢ ts' vs'
  sfundthrmˢ {ts = ts} reflˢ         q = idextˢ ts q 
  sfundthrmˢ (symˢ p)      q = sym∼ˢ (sfundthrmˢ p (sym∼ˢ q)) 
  sfundthrmˢ (transˢ p p') q = 
    trans∼ˢ (sfundthrmˢ p (trans∼ˢ q (sym∼ˢ q)))
             (sfundthrmˢ p' q)  
  sfundthrmˢ (cong< p p')  q = ∼<< (sfundthrmˢ p q) (sfundthrm p' q) 
  sfundthrmˢ (cong○ p p')  q = sfundthrmˢ p (sfundthrmˢ p' q ) 
  sfundthrmˢ idcomp        (∼<< q q') = ∼<< q q' 
  sfundthrmˢ {ts' = ts} popcomp       q = idextˢ ts q 
  sfundthrmˢ {ts' = ts} leftidˢ       q = idextˢ ts q 
  sfundthrmˢ {ts' = ts} rightidˢ      q = idextˢ ts q 
  sfundthrmˢ {ts = (ts ○ ts') ○ ts''} assoc         q = idextˢ ts (idextˢ ts' (idextˢ ts'' q)) 
  sfundthrmˢ {ts = (ts < t) ○ ts'} comp<         q = 
   ∼<< (idextˢ ts (idextˢ ts' q)) (idext t (idextˢ ts' q)) 

mutual
  squotlema : ∀ {Γ σ}{v v' : Val Γ σ} → 
               v ∼ v' → quot v ≡ quot v'
  squotlema {σ = ι}    {nev n}{nev n'} p = cong ne p 
  squotlema {Γ}{σ ⇒ τ}                 p = 
    cong λn (squotlema {σ = τ} (p (weak σ) q)) 
    where
    q = squotlemb refl
  squotlema {σ = One}                  p = refl 
  squotlema {σ = σ * τ} (p , q) = cong₂ <_,_>n (squotlema p) (squotlema q) 

  squotlemb : ∀ {Γ σ}{n n' : NeV Γ σ} → 
               quotⁿ n ≡ quotⁿ n' → nev n ∼ nev n'
  squotlemb {σ = ι}     p = p 
  squotlemb {σ = σ ⇒ τ}{n}{n'} p = λ f q → 
    let q' = squotlema {σ = σ} q     
    in  squotlemb {σ = τ} 
                   (cong₂ appN 
                          (trans (qⁿmaplem f n) 
                                  (trans (cong (nenmap f) p) 
                                          (sym (qⁿmaplem f n')))) 
                          q')   
  squotlemb {σ = One}   p = tt
  squotlemb {σ = σ * τ} p = squotlemb (cong fstN p) , squotlemb (cong sndN p) 

sndvar : ∀ {Γ σ}(x : Var Γ σ) → nev (varV x) ∼ nev (varV x)
sndvar x = squotlemb refl

sndid : ∀ Γ → (vid {Γ}) ∼ˢ (vid {Γ})
sndid ε       = ∼ε 
sndid (Γ < σ) = ∼<< (∼ˢmap (skip σ oid) (sndid Γ)) (sndvar vZ) 

soundthrm : ∀ {Γ σ}{t t' : Tm Γ σ} → t ≈ t' → nf t ≡ nf t'
soundthrm {Γ}{σ} p = squotlema {σ = σ} (sfundthrm p (sndid Γ)) 
