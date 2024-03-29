#check Nat
#check List Nat

#check Type
#check List Type

def cons (α : Type) (a : α) (as : List α) : List α :=
  List.cons a as

#check cons

-- (α : Type) → α → List α → List α
-- Dependent function type
-- Unlike Nat -> Nat. α is a parameter

universe u
def Lst (α : Type u) : Type u := List α
-- To generalize over higher order types (or whatever it is), use universe

def ident {α : Type u} (x : α) := x
#check ident         -- ?m → ?m
#check ident 1       -- Nat
#check ident "hello" -- String
#check @ident        -- {α : Type u_1} → α → α

variable {α : Type u}

def infernot {a: Nat} := a

#eval @infernot 2

variable (p q: Prop)

#check p→ q

variable (x y: Sort 1)
#check x→y

variable (x y: Sort 0)
#check x→y

theorem t1 {p q : Prop} (hp : p) (hq : q) : p := hp

theorem t2 : ∀ {p q : Prop}, p → q → p :=
  fun {p q : Prop} (hp : p) (hq : q) => hp -- params generated

-- p, q are params, and other params are of types dependent on them

theorem tx (p q : Prop) (hp : p) (hq : q) : p := hp

variable (p q r s : Prop)

#check tx
#check tx r s -- types and values are the same thing
-- first two arguments applied, producing a new function

-- propositions are of type Prop. P: Prop
-- proofs of propositions : P
-- any two instances of type P are definitionly equal


example (hp : p) (hq : q) : p ∧ q := And.intro hp hq

-- build a p ^ q with hp and hq

example (hp : p) (hq : q) : p ∧ q := ⟨hp, hq⟩ -- anon cosntructor

-- Structure is a collection of fields
-- Accessor function takes a structure and returns the field

variable (p q r : Prop)

example (h : p ∨ q) : q ∨ p :=
  Or.elim h
    (fun hp : p =>
      show q ∨ p from Or.intro_right q hp)
    (fun hq : q =>
      show q ∨ p from Or.intro_left p hq)

-- existence of fn p → q ∨ p represents that we can construct a proof that q ∨ p from p
-- therefore p is the premise, q ∨ p is the conclusion
-- eliminates the or with two implications to a common conclusion

#check False

variable (hp: p) (hnp: ¬p)

#check ¬p
#check hnp hp

example (hpq : p → q) (hnq : ¬q) : ¬p :=
  fun hp : p =>
  show False from hnq (hpq hp)

example (h : p ∧ q) : q ∧ p :=
  have hp : p := h.left -- wraps them in lambdas and stores sub-goal proofs in arguments
  have hq : q := h.right
  show q ∧ p from And.intro hq hp

open Classical

#check em p
#check absurd

theorem dne {p : Prop} (h : ¬¬p) : p :=
  Or.elim (em p)
    (fun hp : p => hp)
    (fun hnp : ¬p => absurd hnp h) -- why can i use absurd

example (h : ¬¬p) : p :=
  byContradiction
    (fun h1 : ¬p =>
     show False from h h1)



-- commutativity of ∧ and ∨
example : p ∧ q ↔ q ∧ p := ⟨(fun ha: p ∧ q => ⟨ha.right, ha.left⟩), (fun ha: q ∧ p => ⟨ha.right, ha.left⟩)⟩
example : p ∨ q ↔ q ∨ p := sorry

#check λ a: Nat => 2

-- associativity of ∧ and ∨
example : (p ∧ q) ∧ r ↔ p ∧ (q ∧ r) := ⟨λ ha => have qr: q ∧ r := ⟨ha.left.right,ha.right⟩
  have hp := ha.left.left
  ⟨hp, qr⟩, λ hr => let pq := ⟨hr.left,hr.right.left⟩; ⟨pq, hr.right.right⟩⟩
example : (p ∨ q) ∨ r ↔ p ∨ (q ∨ r) := sorry

-- distributivity
example : p ∧ (q ∨ r) ↔ (p ∧ q) ∨ (p ∧ r) := sorry
example : p ∨ (q ∧ r) ↔ (p ∨ q) ∧ (p ∨ r) := sorry

-- other properties
example : (p → (q → r)) ↔ (p ∧ q → r) := sorry
example : ((p ∨ q) → r) ↔ (p → r) ∧ (q → r) := sorry
example : ¬(p ∨ q) ↔ ¬p ∧ ¬q := sorry
example : ¬p ∨ ¬q → ¬(p ∧ q) := sorry
example : ¬(p ∧ ¬p) := sorry
example : p ∧ ¬q → ¬(p → q) := sorry
example : ¬p → (p → q) := sorry
example : (¬p ∨ q) → (p → q) := sorry
example : p ∨ False ↔ p := sorry
example : p ∧ False ↔ False := sorry
example : (p → q) → (¬q → ¬p) := sorry


#check ¬p
#check ¬¬p

open Classical

variable (p q r : Prop)

example : (p → q ∨ r) → ((p → q) ∨ (p → r)) := (λ pr => byCases (λ hq: q => Or.intro_left _ (λ _: p => hq)) (λ hnq: ¬q => Or.intro_right _ (λ xp: p =>
    let qr: q ∨ r := pr xp;
    qr.elim (λ hq => absurd hq hnq) (λ hr => hr)
  )))
example : ¬(p ∧ q) → ¬p ∨ ¬q := λ hn => byCases (λ hp: p => (
  byCases (λ hq => absurd ⟨hp, hq⟩ hn) (λ hnq => Or.inr hnq)
)) (λ hnp => Or.inl hnp)
example : ¬(p → q) → p ∧ ¬q := fun hn =>
  byCases (fun hp: p => let nq := byContradiction (fun hq: ¬¬q => hn (fun hp: p => byContradiction (fun nq: ¬q => hq nq))); ⟨hp, nq⟩)
    (fun hnp: ¬p =>  -- it must explode as p ∧ ¬q cant be introed
      byCases (fun hq: q => absurd (fun hp: p => hq) hn)
        (fun hnq: ¬q =>
          let imp := (fun hp: p => show q from absurd hp hnp);
          absurd imp hn
        )
    )
example (hp: p): q → p := fun hq: q => hp
-- in all worlds where p is true, q → p

example : (p → q) → (¬p ∨ q) := fun ptoq =>
  byCases (fun hq: q => Or.inr hq) (fun hnq: ¬q => byCases (fun hp: p => let hq := ptoq hp; absurd hq hnq)
    (fun hnp: ¬p => Or.inl hnp))
example : (¬q → ¬p) → (p → q) := fun npnq =>
  fun hp: p => -- all usable parameters are assumptions
    byContradiction (fun nq => npnq nq hp)
example : p ∨ ¬p := em p
example : (((p → q) → p) → p) := sorry

-- universal quantifer represented as func with (arbitary) paramter instance over a type

variable (p: α → Prop)
-- predicate producer

def forall1 := ∀ x: α, p x

theorem proof1: ∀ x: α, p x :=
  sorry

variable (α : Type) (r : α → α → Prop)

variable (refl_r : ∀ x, r x x)
variable (symm_r : ∀ {x y}, r x y → r y x)
variable (trans_r : ∀ {x y z}, r x y → r y z → r x z)

example (a b c d : α) (hab : r a b) (hcb : r c b) (hcd : r c d) : r a d :=
  trans_r (trans_r hab (symm_r hcb)) hcd

#check Sort 0
#check Sort 1

#check Eq.symm
#check Eq.refl

variable (α β : Type)

example (f : α → β) (a : α) : (fun x => f x) a = f a := Eq.refl _
example (a : α) (b : β) : (a, b).1 = a := Eq.refl _
example : 2 + 3 = 5 := Eq.refl _
example : 2 + 3 = 5 := Eq.refl 5
example : 2 + 3 = 5 := rfl

-- term reduction


example (α : Type) (a b : α) (p : α → Prop)
        (h1 : a = b) (h2 : p a) : p b :=
  Eq.subst h1 h2  -- make a proof of p b from p a

example (α : Type) (a b : α) (p : α → Prop)
    (h1 : a = b) (h2 : p a) : p b :=
  h1 ▸ h2

#check congrArg

variable (a b c d e : Nat)
variable (h1 : a = b)
variable (h2 : b = c + 1)
variable (h3 : c = d)
variable (h4 : e = 1 + d)

theorem T : a = e :=
  calc
    a = b      := h1
    _ = c + 1  := h2
    _ = d + 1  := congrArg Nat.succ h3
    _ = 1 + d  := Nat.add_comm d 1
    _ = e      := Eq.symm h4

variable (x y : Nat)

def divides : Prop :=
  ∃ k, k*x = y

#check divides
#check Exists.intro

def divides_trans (h₁ : divides x y) (h₂ : divides y z) : divides x z :=
  let ⟨k₁, d₁⟩ := h₁
  let ⟨k₂, d₂⟩ := h₂
  ⟨k₁ * k₂, by rw [Nat.mul_comm k₁ k₂, Nat.mul_assoc, d₁, d₂]⟩

variable (α : Type) (p q : α → Prop)

example (h : ∃ x, p x ∧ q x) : ∃ x, q x ∧ p x :=
  Exists.elim h
    (fun w =>
     fun hw : p w ∧ q w =>
     show ∃ x, q x ∧ p x from ⟨w, hw.right, hw.left⟩)

example (h : ∃ x, p x ∧ q x) : ∃ x, q x ∧ p x :=
  match h with
  | ⟨w, hw⟩ => ⟨w, hw.right, hw.left⟩

example (h : ∃ x, p x ∧ q x) : ∃ x, q x ∧ p x :=
  let ⟨w, hpw, hqw⟩ := h
  ⟨w, hqw, hpw⟩

example : (∃ x, p x ∧ q x) → ∃ x, q x ∧ p x :=
  fun ⟨w, hpw, hqw⟩ => ⟨w, hqw, hpw⟩

variable (α : Type) (p q : α → Prop)
variable (r : Prop)

example : (∃ x : α, r) → r :=
  fun ⟨t,p⟩ => p

example (a : α) : r → (∃ x : α, r) :=
  fun k => ⟨a, k⟩

example : (∃ x, p x ∧ r) ↔ (∃ x, p x) ∧ r :=
  ⟨
    fun ⟨t, left, right⟩ => ⟨⟨t, left⟩, right⟩,
    fun ⟨⟨t, k⟩, n⟩ => ⟨t, k, n⟩
  ⟩

example : (∃ x, p x ∨ q x) ↔ (∃ x, p x) ∨ (∃ x, q x) :=
  ⟨
    fun ⟨i, hp⟩ => hp.elim (fun hl => Or.inl ⟨i, hl⟩) (fun hr => Or.inr ⟨i, hr⟩),
    fun or => or.elim (fun ⟨i,hp⟩ => ⟨i, Or.inl hp⟩) (fun ⟨i,hp⟩ => ⟨i, Or.inr hp⟩)
  ⟩

example : (∀ x, p x) ↔ ¬ (∃ x, ¬ p x) := sorry

example : (∃ x, p x) ↔ ¬ (∀ x, ¬ p x) := sorry
example : (¬ ∃ x, p x) ↔ (∀ x, ¬ p x) := sorry
example : (¬ ∀ x, p x) ↔ (∃ x, ¬ p x) := sorry

example : (∀ x, p x → r) ↔ (∃ x, p x) → r := sorry
example (a : α) : (∃ x, p x → r) ↔ (∀ x, p x) → r := sorry
example (a : α) : (∃ x, r → p x) ↔ (r → ∃ x, p x) := sorry

variable (f : Nat → Nat)
variable (h : ∀ x : Nat, f x ≤ f (x + 1))

example : f 0 ≤ f 3 :=
  have  : f 0 ≤ f 1 := h 0
  have : f 0 ≤ f 2 := Nat.le_trans this (h 1)
  show f 0 ≤ f 3 from Nat.le_trans this (h 2)

example : f 0 ≤ f 3 :=
  have : f 0 ≤ f 1 := h 0
  have : f 0 ≤ f 2 := Nat.le_trans (by assumption) (h 1)
  show f 0 ≤ f 3 from Nat.le_trans ‹_› (h 2)

theorem test (p q : Prop) (hp : p) (hq : q) : p ∧ q ∧ p := by
  apply And.intro
  exact hp
  apply And.intro
  exact hq
  exact hp

theorem test2 (p q : Prop) (hp : p) (hq : q) : p ∧ q ∧ p := by
  apply And.intro
  case left => exact hp -- tagged goals. goals are terms(proofs) demanded.
  case right =>
    apply And.intro
    case left => exact hq
    case right => exact hp

theorem test3 (p q : Prop) (hp : p) (hq : q) : p ∧ q ∧ p := by
  apply And.intro
  . exact hp
  . apply And.intro
    . exact hq
    . exact hp

example (p q r : Prop) : p ∧ (q ∨ r) ↔ (p ∧ q) ∨ (p ∧ r) := by
  apply Iff.intro
  . intro h -- function parameter. aka hypothesis
    apply Or.elim (And.right h)
    . intro hq
      apply Or.inl
      apply And.intro
      . exact And.left h
      . exact hq
    . intro hr
      apply Or.inr
      apply And.intro
      . exact And.left h
      . exact hr
  . intro h
    apply Or.elim h
    . intro hpq
      apply And.intro
      . exact And.left hpq
      . apply Or.inl
        exact And.right hpq
    . intro hpr
      apply And.intro
      . exact And.left hpr
      . apply Or.inr
        exact And.right hpr

example (x y z w : Nat) (h₁ : x = y) (h₂ : y = z) (h₃ : z = w) : x = w := by
  apply Eq.trans h₁
  apply Eq.trans h₂
  assumption   -- applied h₃

example : ∀ a b c d : Nat, a = b → a = d → a = c → c = b := by
  intros
  rename_i h1 _ h2
  apply Eq.trans
  apply Eq.symm
  exact h2
  exact h1

example : 2 + 3 = 5 := by
  generalize h : 3 = x
  -- goal is x : Nat, h : 3 = x ⊢ 2 + x = 5
  rw [← h]

example (p q : Prop) : p ∧ q → q ∧ p := by
  intro h
  cases h with
  | intro hp hq => constructor; exact hq; exact hp

example (f : Nat → Nat) (k : Nat) (h₁ : f 0 = 0) (h₂ : k = 0) : f k = 0 := by
  rw [h₂] -- replace k with 0
  rw [h₁] -- replace f 0 with 0

#check @Nat.rec -- rec, to construct
