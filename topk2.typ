
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

$m_2(|q|)=m."ed"+|q|-m.i=m."ed"$