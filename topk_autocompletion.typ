
- Paper from http://www.vldb.org/pvldb/vol9/p828-deng.pdf

- Indeed I must use a personal notation to serialize my ideas cause my brain has too small a cache.

- https://blog.burntsushi.net/transducers/#finite-state-machines-as-data-structures

- A deterministic acyclic finite state acceptor is a finite state machine
  - It accepts the state, or not.
- A deterministic acyclic finite state transducer is a finite state machine 
  - A transducer. This means that the finite state machine emits a value associated with the specific sequence of inputs given to the machine. A value is emitted if and only if the sequence of inputs causes the machine to end in a final state.
- a deterministic finite automaton (DFA)—also known as deterministic finite acceptor 

- That means, a levenshtein automaton is a state machine that you feed a sequence of bytes, and it can reach a state of acceptance. #link("https://julesjacobs.com/2015/06/17/disqus-levenshtein-simple-and-fast.html")[see]

= Top-k completion

= 

- Threshold #sym.tau 
- _active nodes_  the trie nodes whose edit distances to the query are within the threshold
  - the leafs are answers
- guarantee eachtrie node is accessed at most once (see Section 5).
- Edit distance $"ED"(q,s)$ 
- $s[i]$, $s[i,j]$ $s[1,0]=phi.alt$
- $"PED"(q,s)$, minimum ED from q to any prefix of s 
- $q_i "for" q[1,i]$
- Active node set $A_i$ for $q_i$
  - This paper avoids redundant $A_i$ computations
  - $A_(i+1) "for" q_(i+1)$ 
- ETA, Error-Tolerant Autocompletion

```
However, the SSS techniques cannot efficiently sup-
port the ETA problem [7,14,18,30], because (i) they generate
huge number of prefixes and (ii) cannot share the computa-
tions between the continuous queries typed letter by letter.
```

+ ```
 Our proposed techniques can support the
ETA query with multiple words (e.g., the person name). We
first split them to single words and add them to the trie
index. Then for a multiple-word query, we return the inter-
section of the result sets of each query word as the results.
Moreover, the techniques in [14,18] to support multiple-word
query using the single-word error-tolerant autocompletion
methods also apply to META
```
+ ```
Firstly, we can aggregate edit distance with other functions using a linear com-
bination, e.g., combining edit distance with TF/IDF. Then
we can use the TA algorithm [11] to compute the answers.
The TA algorithm takes as input several ranked score lists,
e.g., the list of strings sorted by edit distance to the query
string and the list of strings sorted by TF/IDF. Note that
the second list can be gotten offline and we need to com-
pute the first list online. Obviously our method can be used
to get the first list, i.e., top-k strings. (2) We can use our
method as the first step to generate k data strings with the
smallest prefix edit distance to the query, and then re-rank
these data strings by the other scoring functions.
```

== Matching to Edit Distance

- *matching*, $"for any" q[x] = s[y]$, the matching is $(q[x],s[y],"ED"(q_x,s_y))$
- $cal(M)(q,s)$ denotes the matching set between q and s
  - $forall cal(M), (0,0,0) in cal(M) $, as index starts from 1.


For any matching, the perceived $"ED"(q,s)_"pmin" = "ED"(q_x,s_y)+max(|q|-x,|s|-y)$ at which we can sure $"ED"(q,s)_"pmin" >= "ED"(q,s)_"real"$

with the current state of knowledge about matching, the certainly-works minimum is such. As we go right to the right most matching, the perceived $"ED"_min$ decreases, until $"ED"_min="ED"$

- For a $(q,s)$, for *a* matching $m=(x,y,"ED")$, the corresponding Deduced Edit Distance is $m(|q|,|s|)="ED"(q,s)_"pmin"$ 

$m(|q|,|s|)$ is how the paper denotes DED, which is ED of two prefixes in the matching, plus a max over q and s.
This valued is completely determined by the matching $m$ and $|q|,|s|$

Lemma 1, $forall (q,s), min("ED"(q,s)_"pmin") = "ED"(q,s)_"real"$ which takes the last matching in the $cal(M)(q,s)$

- For a matching $(q[x],s[y],"ED"(q_x,s_y))$, $"PED"(q,s)_"pmin"="ED"(q_x,s_y)+(|q|-x)$

Similarly, Lemma 2

$forall (q,s), min("PED"(q,s)_"pmin") = "PED"(q,s)_"real"$ which takes the last matching in the $cal(M)(q,s)$

Thus for a (q,s) and $cal(M)(q,s)$ we can derive the PED and ED.

For a (q,s), with the last matching we can derive $"PED"(q,s)$ and $"ED"(q,s)$, and inferior approximates with other matchings 

for a matching $m(x,y)$, the Deduced prefix edit distance is denoted by $m_(|q|)="ED"(q_x,s_y)+(|q|-x)$.

in which $m$ and $|q|$ completely determines the value.

=== Calculating $cal(M)$

$M(q_(x-1),s) subset.eq M(q_x,s) $ 

Lemma 3. For q and s, for any $q[x]=s[y]$, 
$"ED"(q_x,s_y)="ED"(q_(x-1),s_(y-1))$ (Ukkonen)

by Lemma 1, $"ED"(q_x,s_y)="ED"(q_(x-1),s_(y-1))=min("ED"(q_(x-1),s_(y-1))_"pmin")$

== Trie

A node represents a prefix. 

Therefore, a matching is $m(x,y)$, equally $m(x,n)$

$m(x,n)$ is an active matching of q and n is an active node thereof $"iff" m_(|q|) < tau$

$cal(A)(q,cal(T))$, set of active matchings between q and a trie 

$|n|="depth"$

For $cal(A)(q,cal(T))$, result is all the leaves in $cal(A)$

$b_i$ is the max PED between $q_i$ and topk-k results of $q_i$

= Inverted index

$f("depth","char")->"node"$


```rs
    fn first_deducing(
        &'stored self,
        active_matching_set: &MatchingSet<'stored, UUU, SSS>,
        character: char,
        query_len: usize,
        threshold: usize,
    ) -> MatchingSet<'stored, UUU, SSS> {
```

- active_matching_set, $cal(A)_(i-1)$
- character, $q[i]$
- query_len, $i$


```rust
// Node to ED
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
```

1. Traverse each descendent of each member of $A_(i-1)$, filter them by $n."char"==q[i]$

```rust
 let bound = matching.deduced_edit_distance(
                        query_len - 1,
                        node.depth.saturating_sub(1) as usize,
                    );
```

$m_(i-1,|n|-1)$

```rs
// m, |q|, |s|
    fn deduced_edit_distance(&self, query_len: usize, stored_len: usize) -> usize {
        self.edit_distance as usize
            + max(
                query_len.saturating_sub(self.query_prefix_len as usize),
                stored_len.saturating_sub(self.node.depth as usize),
            )
    }
```

$"ED"(q,s)_"pmin" = "ED"(q_x,s_y)+max(|q|-x,|s|-y)$

2. `best_edit_distances` is updated with lower values


```rs
        *set_delta = self.first_deducing(
            active_matching_set,
            character,
            query_len,
            threshold.saturating_sub(1),
        );

       for matching in active_matching_set.iter().chain(set_delta.iter()) {
            let prefix_edit_distance = matching.deduced_prefix_edit_distance(query_len);
            if prefix_edit_distance < threshold {
                if self.fill_results(matching.node, prefix_edit_distance, result, requested) {
                    return threshold;
                }
            }
        }
```

Why does it collect DEDmin to a map.

`active_matching_set.iter().chain(set_delta.iter())`, $A_(i-1) + Delta$ 

== Definition 7

$m_i <= tau <=> m in cal(A)(q_i,cal(T))$ 

== Active matching and answer

$forall s in R$ (answer set)

there exists at least one $m, s.t. m_(|q|)<=tau$, by $"PED"(q,s)=min(m_(|q|))$. (at least the last matching has its DPED <= $tau$)

$m=s_j$

By definition 7, it's an active matching of $q$

#set math.cases(reverse: false)
$
cases(
  m_(i-1) < m_(i-1, |n''|-1) <= tau ,
  "ED"(q_i,n'') = min(m_(i-1, |n''|-1))
) 
$

- First kind, $m(i',j',"ed"),i'<i$

$m_i<tau => m_i-1=m_(i-1)<tau-1$

$m_(|q|)="ED"_m+(|q|-x), m_(|q|-1)="ED"_m+(|q|-1-x)$

Therefore they can be get from $A_(i-1)$

- Second kind,  $m(i',j',"ed"),i'=i$

In $m_i <= tau <=> m in cal(A)(q_i,cal(T))$ 

$m_i$ is the lowest known upper bound of PED. 


= $m'_(i-1,|n|-1)$

=

For $n''$, $n''."char"=q[i]$, by lemma 3, $"ED"(q_i,n)="ED"(q_(i-1),n."parent")$=$limits(min)_(m in M(q_(i-1),n."parent"))(m_(i-1,|n''|-1))$

$forall m_(q,s), m_q < m_(q,s)$


A matching is two strings, and they derive an ED. 

$m_(q,s)$ is a *function* over (querylen, storedlen). Each $m$ corresponds to a function.

When m is the last matching, it computes the exact $"ED"(q,s)$

By computing $m_(q,s)$ such that $m_(q,s)<=tau$, we have $m_q<=m_(q,s)<=tau$ 

$m_(|q|)="ED"_m+(|q|-x) <= m_(|q|,|s|) = "ED"_m+max(|q|-x,|s|-y)$

== Compact trie

The paper means some descendents have been visited during the `traverse_inverted_index` of an ancestor node, so next time the visits can be eliminated as a whole, when $n."range" subset.eq p."range"$


$
 cases(forall s in R\, "PED"(q,s)<tau => min_(m_q,m in M(q,s)) < tau,
  forall m (i,n,"ed")\, m_q <= tau <=> m in A_q) => "All s" in R "is reachable from" cal(A)
$

= Top K

$b_i = max_(s in R_i)"PED"(q_i,s)$, where $R_i$ is $q_i$'s Top-K results.

$b_i = cases(b_(i-1),b_(i-1)+1)$

$forall s in R_(i-1), "PED"(q_i,s) = "PED"(q_(i-1),s) + 1 <= b_(i-1) + 1$ where $|R_(i-1)|=k$

They are the upper bound of PED for $R_i$, as we can always take $R_(i-1)$ as $R_i$. 

$forall s, "PED"(q_i,s)>="PED"(q_(i-1),s) =>_("but why") b_i >= b_(i-1)$ 

For $R_i$,

+ Find results $s,"PED"(q,s)<b_(i-1)$
+ Find results $s,"PED"(q,s)=b_(i-1)$, update $b_i$
+ Find results $s,"PED"(q,s)=b_(i-1)+1$, update $b_i$

b-matching, (i,n,ed), $"iff" "ed" <= b$

$P(q,b)$ denotes the set of *all* b-matchings of q
- for such a matching, $(i,n,"ed")$, $i_m<i_q$
- it is exhaustive

$forall s, "PED"(q,s) =_(m "is the last matching") "ed"_m + |q|-i_m <= b, exists m(i,n,"ed"_m), "ed"_m <= b$

Therefore from $P(q,b)$ we can get $R$, exhaustively.

== Calculating b-matching 
=


=== 1. $P(q_i,b-1)$

for an $m(i,n,"ed") in P(q_i,b-1), text(cases(i_m<i_q =>_("ed"<=b-1<=b) m in P(q_(i-1),b) \, "the first kind", i_m=i_q), size: #1.5em)$

By $P(i-1,b)$ being exhaustive, the first kind can be all got from $P(i-1,b)$

For the second case, descendents of matchings are enumerated. 

for $m'=(i',n',"ed"') in P(q_(i-1),b)$, find every $n_d$

$text(cases(n_d (n'') "is a descendent of " n', m'(i-1,|n_d|-1) <= b-1, n_d."char"=q[i]), size: #1.2em)$

for $m(i,n), m_(a,b) =_min "ed" "if" a=i,b=n$

$"ED"(q, n_d) =_"Lemma3" "ED"(q_(i-1), n_d."parent") = min_(m' in M(q_(i-1),n_d."parent"))m'(i-1, |n_d|-1)$

In the second case, $i_m = i_q= i'' ("in paper")$

$"ed"'':="ED"(q_i, n_d)$. Thus this produces the part of $ P(q_i,b-1)$ where $i_m=i_q$

=== 2. $P(q_i,b)$

$P(q_i,b) supset.eq P(q_i,b-1) "by def"$

For $m(q,n)$, denote $m(q_(i-1),n."parent")$ as $m_(-1)$

$"ED"(m'')="ED"(m''_(-1))$

For a matching $m(i,n,"ed")$

$text(cases("ed"="ED"(q_i,n."prefix")=m_(q,n),q[i]=n."char",), size: #1.2em)$

Denote $M=M(q_i'',n'')$

Find $m' in M_(-1)$ st. $"ed"'' = m'_(i''-1,|n''|-1)  text(cases(="ed"' (m'=m''_(-1)), > "ed"'), size: #1.2em)$

Denote the goal, exact b-matchings to be $m''=(i'',n'',"ed"''=b) in P(q_i,b)- P(q_i,b-1)$

-  By definition, $q[i'']=n''."char"$

Enumerate every (b-1)-matchings, $m'(i',n',"ed"') in P(q_i,b-1)$

Find all descendents $n''$ such that 

$text(cases(q[i'']=n''."char",
m'(i''-1,|n''|-1)=b,
 (i'',n'',*) in.not P(q_i,b-1)),
 size: #1.2em)
$

$text(cases(
(i'',n'',*) in.not P(q_i,b-1) => "ED"(q_i'',n'')>b-1 => "ED"(q_i'',n'') >= b,
m'(i''-1,|n''|-1)=b="ED"+ k_(>=0) => "ED"_m' <= b,
 reverse: #true) => "ed"'' = b
,size: #1.2em)
$

$i'', n''$ etc. are variables to be solved.

Till now, all three parts have been produced.

+ $P(q, b-1)$ 
  + $i_m< i$, exactly $P(q_(i-1),b)$
  + $i_m=i$, enumerate descendents of $P(q_(i-1),b)$
+ $P(q,b) - P(q,b-1)$, enumerate descendents of $P(q,b-1)$