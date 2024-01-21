
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

#pagebreak()

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

By inferring from the requirement that $m_2(|q|-1,|n_2|-1)<=tau$.

$
m_1=(i_1,n_1=(c_1,d_1)) \
cases(
k=m_1(|q|-1,|n_2|-1) = m_1."ed"+max(|q|-1-i_1,|n_2|-1-|n_1|) <= tau \
k>=|n_2|-1-|n_1| 
) \ 
=> |n_2|-1-|n_1| <= tau => |n_2|<=|n_1|+tau+1
$

which holds, given $m_1$ exists

== Theorem when $m.i < |q|$

$
beta = {m|m in A(q_i) and m.i < i=|q|} \

forall m, i, cases(
  m_i=m."ed"+ i-m.i,
  m_(i-1)=m."ed"+(i-1)-m.i = m_i-1
)
\
m in beta => m in A_(i-1) \
m_(i)<=tau=>m_(i-1)=m_i-1=tau-1<=tau => m in A_(i-1)
\
m in A_(i-1) arrow.r.double.not m in beta
\
forall m in A_i, m.i<=i
$