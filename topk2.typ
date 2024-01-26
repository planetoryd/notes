
Notes for http://www.vldb.org/pvldb/vol9/p828-deng.pdf

#heading(numbering: "1.", "Matching prefix")

\

consider a full query string, $q=q[1,"len"]$

$
cases(q[1,j], 0<=j<="len"=|q|, q[1,0]=phi.alt) 
$

we are currently searching $q[i]$

consider any full stored string $s$, a prefix is $s[1,k]=s_k$

an (end) matching prefix $s[1,j]$ is defined to be a prefix ending with $q[i] = s[j]$ $=> "ED" := "ED"(q[1,i],s[1,j]) = "ED"(q[1,i-1],s[1,j-1])$ 

which calculates the ED between current query and the matching prefix.

for substring $q[1,i-1] "and" s[1,j-1]$, set of matchings is $M_(q,s)$ where $"ED"=min_(m in M)(m_(|i-1|,|j-1|))$

Therefore for a *matching prefix*, it must be possible to find the minimal $m_(k,|i-1|,|j-1|)$. This computation depends on $m_k$ and $(|i-1|,|j-1|)$ determinstically

The root node has $"ED"=1$, and $m^"root"_(k,|i-1|,|j-1|)=max(|i-1|,|j-1|)$ For a matching prefix and a $q_i$ they may have no other matchings except root. At this point the theorem still holds. (according to the paper it seems.)  

$M(q_0,s)={(i=0,j=0,"ED"=0)}$

To make sure we can calculate the matching prefix ED to query, we make sure for a newly discovered matching prefix, all previous matchings are discovered. 

Equally, finding matchings further from a known matching makes sure the set of "previous matchings" is exhaustive.

Q1: It's not clear how that way of scanning descendents against $q[i]$ the "previous matchings" are exhaustive

Thus, the ED of $q[i]$ and $n$ (prefix of node n) is computed by iterating over "previous matchings"

Q1 is answered by, $m$ is an active matching of $q_(i-1)$. $m in A subset.eq M$. Therefore we dont need exhaustive $M$. 

$M=M(q_(i-1),n."parent")$. Trivially, $A subset.eq M$. 

Require $"eq"(q_i,n)=min(m_(i-1,|n|-1))<=tau => $ We need $m_(i-1,|n|-1) <= tau$, Find min. 

$
cases(
  "for any" m  \
  m_(|q|)=m."ed"+|q|-m.i \
  m_(|i-1|) <= m_(i-1,|n|-1) ("trivial")
)
=>  forall "m we need", m_(|q|) <= tau
\
m in A_q <=> m_(|q|) <= tau
=> forall m_("need") in A(q_(i-1))
$

Therefore $M(q_(i-1),n."parent")$ (the previous matchings) is not needed, but only the relevant subset.

Q2: How is $A(q_(i-1))$ exhaustive by that algorithm. ie. prove for some q $forall  m_(|q|) <= tau => m in A_q$

For some $q, |q|=i, forall  m_(|q|) <= tau => m in A_q$
$
cases(
  1. forall m.i = |q| = i space ("end matching prefixes"),  
  2. forall m.i < i  space ("taken from" A(q_(i-1))) 
)
$

Type 1 is collected through iterating over descendents, and filtering the matchings by $"ed" < tau$, while ed is computed by looping over $A(q_(i-1))$. One ed is computed for each $j-1 => j$

Q3: How is type 1 searching exhaustive. 

$tack "for certain depth of nodes", forall m in A(q_(i-1)), m_(i-1,|n|-1) > tau $, so they are always excluded.

$tack "for" m_1(i_1,n_1) in A(q_(i-1)), forall m_2 :=(i_2=|q|, n=(c,d)), 
d in.not [n_1.d+1,n_1.d+1+tau] => m_2."ed" > tau$

$
m_2(|q|)=m_2."ed"+|q|-m_2.i=_(m_2.i=|q|)m_2."ed" \
"lev"(a,b) in [ |\|a|-|b|\|, max(|a|,|b|)] \
m_2."ed"="ed"(q,n) in [ |i_2-d|, max(i_2,d)]
$

The paper does utilize features of some particular edit distance algorithm, which are assumptions. TODO: list them later.

No this is different that what is presented in the algorithm. 

$m_2."ed"_min > tau => m_2."ed" > tau => |i_2-d| > tau $

$tack d in.not [i_2-tau,i_2+tau] =K => m_2."ed" >_"certainly" tau \ 
tack m_2."ed" <= tau => d in [i_2 -tau, i_2 + tau]
$

== Experiment 

```rs
    fn first_deducing(
        &'stored self,
        active_matching_set: &MatchingSet<'stored, UUU, SSS>,
        character: char,
        query_len: usize,
        threshold: usize,
    ) -> MatchingSet<'stored, UUU, SSS> {
        let mut best_edit_distances = HashMap::<SSS, UUU>::new();
        for matching in active_matching_set.iter() {
            let node = matching.node;
            let node_prefix_len = node.depth as usize;
            // lines 5-7 of MatchingBasedFramework, also used in SecondDeducing
            for depth in node_prefix_len + 1
                ..=min(
                    node_prefix_len + threshold + 1,
                    self.inverted_index.max_depth(),
                )
            {
                self.traverse_inverted_index(&matching, depth, character, |descendant| {
                    // the depth of a node is equal to the length of its associated prefix
                    let bound = matching.deduced_edit_distance(
                        query_len - 1,
                        node.depth.saturating_sub(1) as usize,
                    );
                    let bound = bound as UUU;
                    let id = descendant.id() as SSS;
                    let pred = depth >= query_len - threshold && depth <= query_len + threshold;
                    if !pred {
                        let k = bound <= threshold as UUU;
                        if k {
                            println!("breach");
                        } 
                    }
```

The above code, via hand-testing, seems to work.

The `best_edit_distances` is a map, $n_2 -> "ed"$ 

$
m_2(i=|q|,n_2) \
"by lev", n_2.d in K\
forall n_2, "all " m_1 in A(q_(i-1)) "are visited" \
n_2."ed" = min(m_1(i-1,|n|-1)) "one value per" m_1, |n|
$

Q4: I'm not sure what justifies the $[\|n|+1,|n|+1+tau]$

$
"for an " m_2(i=|q|,n_2), forall "s" in n_2, exists p = s_(|n|), s.t. "ed"(q,p) <= tau 
  => s in R(q,T)
$

For other matchings, EDs are over $q_(k), k<i=|q|$. EDs over $q_i$ are not necessarily $<= tau$

On lemma 2

$
  "PED"(q,s)=min_(m in M(q,s))(m_(|q|)) \
  tack  "PED"(q,s) = k => exists m_1  in M(q,s), "st." m_1(|q|)=k
$

This is what the paper implies.

$
forall (q,s), "ped"(q,s) = k => exists m_1(q_i,s_j), "st." m_1(|q|)=k \
"given" m_1(|q|)=k, forall s in m_1, "ped"(q,s) <= k 
$

$m:=(q_i,s_j)=(i,n=s_j,"ed")$

Prove $ M={m | m(|q|)<=k} "produces an exhaustive" R, forall s in R, "ped"(q,s)<=k $

$
forall s, "ped"(q,s)=k_1<= k => exists m_1(|q|)=k_1<=k, m_1 in M
$

Inverted Index $f_i: d->c->"vec"_"node"$ 

== Theorem for $m_1$

Further reducing the search range

We require $m_1(|q|-1,|n_2|-1)<=tau$.

$
m_1(|q|-1) <= m_1(|q|-1,|s|) <= tau => m_1 in A(q_(i-1))
$

$
m_1=(i_1,n_1=(c_1,d_1)) \
cases(
"we require" k=m_1(|q|-1,|n_2|-1) = m_1."ed"+max(|q|-1-i_1,|n_2|-1-|n_1|) <= tau \
k>=|n_2|-1-|n_1| 
) \ 
=> |n_2|-1-|n_1| <= tau => |n_2|<=|n_1|+tau+1 \
"by defintion of m(q,s)", q>=m.i and s>=m.j \
=> |n_2|>=|n_1|+1
\
cases(
|q|-1-i_1 <=tau => i_1 >= |q|-1-tau  \ 
m_1."ed" <= tau
) "this is per" m_1 ", the paper didn't talk about this" 
$

which holds, given $m_1$ exists.

$
forall m_1,m_1(alpha,|n_2|-1) <= tau 
=> |n_2| in [ |n_1|+1,|n_1|+tau+1 ]
\
"Narrow down the search domain by" P(m_1,n_2) => Q(m_1,n_2) "which is an interval" \
"Make sure" forall n_2, P(m_1,n_2) \
P, Q "for propositions"  \
$

Every set found by $P$ is a partial. 

$m_1(|q|-1,|n_2|-1)<=tau tack$ the matching set in question $M_t=M(q_(-1),n_2.s_(-1))$

The partials are aggregated by iterating over $m in M_t$. For each iteration find a partial.

$
forall m_1 in M_t => m_1(|q|-1) <= tau "which means we probably already have it" \
M_t => M_2 "this process may expand the set"
$

$M_t$ can not be obtained, as it's different from each $n_2.s_(-1)$.

We just iterate over $M_2$.  

So, this is the core algorithm that produces matchings based on previous matchings.

In $m_1(|q|-1) <= m_1(|q|-1,|s|)=x$, the $x$ part looks creative. The right-hand of *max* can be anything. 

$
m_1(|q|-1) <= m_1(|q|-1,|n|)
$

Any number put in the $|n|$ place, due to the nature of this formula, must mean a node depth.

By introducing, the $m(a,b)$ on the right, we establish a variable of $|n|$.

The end goal is to have $"ed"(q,n_2)<=tau$

$
m_2(|q|) =_(i=|q|) m_2."ed"  <= tau => forall s in m_1.S, "ped"(q,s)<=tau
$

$m_1(i-1,|n_2|-1)$ is an upper bound of $"ed"(q_(i-1),n_2."parent")$

$
"ed"(q_(i-1),n_2."parent") =_(q[i]=n_2."char") "ed"(q_i,n_2)
$

Therefore $m_1(|q|-1,|n_2|-1)<=tau$ but it's an over-requirement.

$
S_(-1):={s,|s|=|n_2|-1}, M_(-1)=M(q_(i-1),n_2."parent"), m_1 in M_(-1)
$

The condition is only satified by a subset of $S_(-1)$, denote it as $S'$

$
forall s in S' => m_1 in M_(-1) (=> s in n_1.S) \
 p_1 :m_1(|q|-1,|s|)<=tau
$

The target set is $S_t = {s, |s| = |n_2|-1 and "ed"(q_(i-1),n_2."parent")<=tau}$

Not every $s in S_t$ satisfies $p_1$

+ If $m_1(|q|-1,|s|) = "ed"(q_(i-1),s)$, the condition keeps $s$, and $s$ meets the goal. \
  There is no $<$ case. \
  $m_1$ is the minium in M.\
  Denote $S(m_1), forall s in S(m_1) => m_min=m_1$. 
  We can retrieve the complete $S(m_1)$ by this condition
+ If $m_1(|q|-1,|s|) > "ed"(q_(i-1),s)$, the condition might drop $s$ \
  Nodes in this case are dropped.

By iterating over every $m in M_(-1)$, for each iteration, we get $S(m)$ \

The loop composes the $S_t$, which is complete.

As, for each $s' in S_t$, the associated $M=M_(-1)$

$
cases(
m'_min in M_(-1) \
forall m in M_(-1) => S(m) subset.eq S_t
) => s' in S(m'_min) subset.eq S_t
\
S_T = S_t "extending each string by" q[i] \
forall s in S_T, 
"ed"(q,s) <=tau
$



== Theorem when $m.i < |q|$

$
beta = {m|m in A(q_i) and m.i < i=|q|} \
alpha = {m|m in A(q_i) and m.i = i=|q|}\

forall m, i, cases(
  m_i=m."ed"+ i-m.i,  
  m_(i-1)=m."ed"+(i-1)-m.i = m_i-1
)
\
forall m in beta => m in A_(i-1) \
m_(i)<=tau=>m_(i-1)=m_i-1=tau-1<=tau => m in A_(i-1)
\
m in A_(i-1) arrow.r.double.not m in beta
\
forall m in A_i, m.i<=i => forall m in A_(i-1), m.i <= i-1<i
$

Therefore in original code it filters the set, $A_(i-1)$ before taking it.

== Node and inverted  index

$
n={|n|="depth",c="character",N,S} \
N "for set of descendents",
S "for set of strings" \
f_i:d->c->vec_n
$ 

When searching, it looks for 
$f_i (d,c) sect n.N$, as (end) matchings.

Process of $sect$ takes a binary search. 
$vec_n$ is a sorted list, N is a range.

for two nodes $n_1$ is a descendant of $n_2 <=> n_1.N subset n_2.N$ 

$
 f_i (d,c)
$

The paper proposes to *aggregate* matchings $m(i,n)$ by node, which removes redundant binary search. For each $m_2$, $m_1$ are enumerated group by group. 

For $N_1=n_1.N subset n_2.N$, the binary search of $n_2$ is dropped, checks are performed on $N_1$, with some unnecessary nodes, but the search should be more expensive. The checks themselves suffice, so using $N_1$ instead of $N_2$ does not cause any problem.

== Active matching set

Lemma 2,

$
forall (q,s), "ped"(q,s)=min_(m in M(q,s))m_(|q|) \
A_i => forall m in A_i, m_(|q|=i)<=tau \
=> (forall m, forall s in m.S, exists m_1=m in M(q,s), m_1(|q|)=k<=tau \
=>"ped"(q,s)<= k
)
$

Any $s$ with that matching has a ped of at most k.

== TopK

$
q, R_q "for results of" q
$

Q1: Does the paper mean, by top-k, $|R_i|=k$  must be true ?

$
R_i:= R(q_i) \
forall s in R_(i-1), "ped"(q,s)<="ped"(q_(i-1),s) + 1\
=> R_(i-1) subset R_i "with ped upper bound (otherwise trivial)" \
=> (forall R_(i-1),R_i  => b_i <= b_(i-1) +1)
$

By deleting one char from $q$, which is the upper bound. 

$
"the trivial case": forall s, "ped"(q,s)=k => s in R_i
$

$
p_1:forall (q,s,i), "ped"(q_i,s) >= "ped"(q_(i-1),s) \
"when both sets are not capped":forall s in S => s in R_i and s in R_(i-1)  => p_1 
$

$
b_i:="ped"(q_i,s_b^i)=max_(s in R_i)("ped"(q_i,s))
$ (defines notation the associated s)

To prove $b_i >= b_(i-1)$

$
cases(
  1. s_b^i = s_b^(i-1) =>_p_1 "ped"(q_i,s_b^i) >=  "ped"(q_i,s_b^(i-1)) \
  2. s_b^i != s_b^(i-1): forall s in R_i\,s != s_b^i =>  "ped"(q_i,s_b^i)>= "ped"(q_i,s)  \
  s_b^(i-1) in R_i => b_i = "ped"(q_i,s_b^i) >= b_(i-1)
)
$

=== More, on the assumptions

Treating them as stateful variables, we can always add $R_(i-1)$ to $R_i$. $forall s in R_(i-1), "ped"(q,s)<="ped"(q_(i-1),s) + 1$. Thus this subset of $R_i$ has a max ped of $b_(i-1) + 1$. Trivially, its always possible to add some absurdly high-ped $s$ to $R_i$.

In the first case, by $p_1$, $b_i >= b_(i-1)$. In the second case, any other string has a ped $<=$ that of $b_i$, which includes $b_(i-1)$

Therefore, we assume we always want to get _best_ or better matchings into $R$, which is in motion. Thus, $b_i <= b_(i-1) + 1$ because we can always use $R_(i-1)$ as the upper bound.

In the same kind of motion, $b_i$ is either from $s_b^(i-1)$ or some other string with worse ped. Again, we can always add $s_b^(i-1)$ to $R_i$. Nothing prevents this. Now we have added $s_b^(i-1)$. We discuss the result by two cases, by making two hypotheses.

$
b_i = b_(i-1) "or" b_(i-1) + 1
$

If $s_b^(i-1) in.not R_i$, we want $forall s in R_i, "ped"(q,s)<=s_1 in (K=S-R_i) forall s_1$

$
"by" b_i = "ped"(q,s_b^i), s_b^i  in R_i, s_b^(i-1) in K => b_i <= b_(i-1) \
R_i != phi.alt
$
2. $s_b^i in R_i => b_i >= b_(i-1)$

It seems $R_i$ is treated as a changing variable. 

=== Reiterate

+ $R_i= phi.alt$

  There is no $b_i$. 

+ $R_i = {"any" s, "ped"(q,s)=0}$

  $b_i = 0 <= b_(i-1)$
  In this case no theorems stated in the paper work. 

+ $exists s_1 in R_(i-1) and s_1 in R_i$ 

  $forall s, "ped"(q,s)<="ped"(q_(i-1),s) + 1\
  => "ped"(q,s_1)<="ped"(q_(i-1),s_1) +1 \
  forall (q,s,i) "ped"(q_i,s) >= "ped"(q_(i-1),s) \
  => "ped"(q,s_1) >= "ped"(q_(i-1),s_1) \
\

  $
  
=== New theorem 

$
forall s in R_(i-1) => "ped"(q_(i-1),s) <= "ped"(q,s) <="ped"(q_(i-1),s) + 1
$

This sets the bounds of the s, which can be added to $R_i$ when necessary.

$
forall s in R_(i-2) => "ped"(q_(i-2),s) <= "ped"(q_(i-1),s) <= "ped"(q,s) <="ped"(q_(i-1),s) + 1 <= "ped"(q_(i-2),s) + 2\
"ped"(q_(i-1),s) <= "ped"(q_(i-2),s) + 1
$

The bounds are determined by *available information*.

- With $ "ped"(q_(i-2),s)$, we can determine a coarse bound.
- With $"ped"(q_(i-1),s)$, it can be further narrowed down.

== Revisitng basic concepts

A matching $m={q_i,s_j}$. This should be the complete information. 

A node is either $n=phi.alt$, or $n=s_j$ (complete information)

$m$ can be used to calculate an upper bound of ED, for any $q,s$. The function only requires $|q|, |s|$, which is $m(|q|,|s|)=m."ed"+max(|q|-m.i,|s|-m.j)$.

m can be used to calculate an upper bound of PED, for any $q$. The function only requires $|q|$
$
m(|q|)=m."ed"+|q|-m.i
$

Here, "any $q$" must extend $q_i$. ($q_i = q[1,i]$). Otherwise $m."ed"$ makes no sense.

// Theorems

=== Theorem upper-bounding PED of Leaves

Given a $m$ and a $|q|$, we can determine the upper bound of PED for all strings sharing $m$. It doesn't even matter what $q$ is.

This can be deduced by supposing $M(q,s)={m}$, applying the equation in the paper, and the actual set can only add more members so it can only get lower.

$
forall s in n_m.S => m in M(q,s) => "ped"(q,s) <= m(|q|)
$

=== Theorem upper-bounding ED of leaves

calculate a upperbound ED, $x= m(|q|,|s|)$, given $|q|,|s|=k$, 

$
forall s in n_m.S and |s|=k => m in M(q,s) => "ed"(q,s) <= x= m(|q|,|s|) \ 

forall s in n_m.S and |s| < k => m in M(q,s) => "ed"(q,s) <= m(|q|,|s|) < x
$

The situation gets complex for $|s| > k$, and it's not worth talking about.

== b-matching

