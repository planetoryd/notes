# Graph transitive modeling

Examples.

- Web of trust
- Websites linking to each other
- Relevance

> Trusted people tend to link to trustworthy people, and quality websites tend to link to quality websites. It is the inherent property of transitivity in things. 

Example trust graph

Me → A → B

If A is trustworthy, and A claims B is trustworthy. Therefore B is trustworthy. (almost tautology ? A's claim is true. The claim is that B's claim is true, and B's claim is ... ) The degree of trustworthiness may decay and accumulate, which is the detail of how different algorithms model it. This deduction is quantitative, and predictive. 

## Websites linking

Bookmarked site → A → B

A is quality content, quality content tends to link to quality content if it intends to (assumption that is probably true), so B is quality content.

Or interpreted as a trust graph, assuming quality means to be trustworthy. A is quality therefore trustworthy, and A claims B is quality. Therefore B is trustworthy.

## Related content, relevance

A ⟺ B ⟺ C

B is related to A and C, so A and C are related too, as it is *probably* true that relevance is transitive unconditionally. B doesn't need to claim anything or be trustworthy since relevance is observed. 

> one method of recommender systems.

## Negative trustworthiness

A is distrustful and holds false claims.

- A distrusts B.

The claim is not trustworthy so it doesn't make sense

- A trusts B

B isn't less trustworthy because A's claims don't count. But empirically, distrustful nodes tend to trust distrustful nodes. It just can't be directly deduced like before.

## Reputation

Trustworthiness is the truthiness of claims. Reputation, by defition, is the tendency of a node to behave well and its contribution to the network, which includes keeping its claims true.

## Interface

- Assumptions. A is trustworthy
- Knowledge, the graph. A trusts B
- Inferred knowledge. B is probably trustworthy

The assumptions should be stored in per-node state. The knowledge is public and shared, stored in contracts. The inferred knowledge can be cached in component internal state.

The node seeks to maximise its knowledge by extracting it from contract states. The node uses all locally available knowledge when doing prediction/inference. (why not)

Infer(knowledge, assumptions) = inferred knowledge

recursive.

Eg. the node stores user assigned trust values of some peers in node state. The graph is stored in a few contracts, which can act as the karma system for a forum. 

> Shortcutting trust graph

- A is trustworthy
- A inferred that B, C, D is trustworthy
- B, C, D are trustworthy

Trust values, therefore may not be additive. 

> About cryptocurrency

It can be built on blockchains, but it may work without consensus too which replaces blockchain in some cases.