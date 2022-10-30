
## Elements of dweb

> Anonymity, Routing, Transport, Verification, Privacy

Things that are trustlessly true in themselves.

1. Self-verifying immutable state store
    - IPFS (or less ideally torrent)
2. Self-verifying mutable state store
    - Freenet/Locutus (or less ideally Matrix)
    - Locutus can provide no authentication in the store, as publickey crypto is not a mandatory part of a contract unlike other protocols.
3. Self-verifying proof of knowledge
    - Publickey crypto / MAC
4. Self-verifying consistency
    - Blockchain
    - It is a mutable state store too, while blockchain like Mina stores minimal state, only a state root hash.
    - [Drand](Drand.love) provides self-verifying consistency over randomness which is not a state store.
5. Self-verifying computation
    - ZKP (not the only solution)
    - Replicating computation, compared and checked in some way.
6. Self-verifying randomness
7. Self-verifying proofs
    - Proof of space, work, usually used in blockchains as votes.

In the case of publickey crypto, you want to make sure some speicific data is signed by the desired author. Through publickey crypto, the statement 'some data is signed by some author' can be verified locally regardless of time and space. In IPFS, 'some piece of data is what I want designated by CID' verifies. In Locutus, 'some state is what I want specified by contract code' verifies, and it holds as the state mutates. 

- CDN ➔ 1
- Databases ➔ 1 or 2, (4)
- DNS ➔ 4 (classic example of consistency, and it is not getting replaced soon)
- Passwords, CA (authentication) ➔ 3, (1, 2, 4) 
- Rendering, static site generation ➔ 5
- Recommenders, Performant search engines ➔ ❎

Tasks of dweb

1. Get the data/information through some *routing* as demanded by the user.
    - Routing doesn't need to be verifiable, since its results can be often verified afterwards.
2. Verify the data, *trust* the unverifiable. 
    - Trust leads to centralization, ie. power

In an extreme case of IP network, users talk to servers, and packets are routed through hierarchical routers. Nothing from servers is verified, everything is trusted. 

There's no verification in the routing. It can get false results, but it works as long as one legit result is returned. Similarly, Locutus state deltas propagate so eventually it is consistent, but this is not verifiable. 

Routing in a general sense. You look for an answer to a question, first from a search engine, and it links to a forum which links to a wiki. They all contain potential answers but the decision is up to you to verify. Search engines shorten the routing but it can alter and censor results.

MPC and federated learning for privacy. Censorship-resistant transport, obfs4, shadowtls. 

### Routing

Multi-steped solution to a problem, involvement of multiple participants.

Routing over multiple centralized servers reduces trust, content routing, eg. IPFS. 

Anonymous routing, I2P, lokinet. E2E routing, yggdrasil. 

- Routing for connectivity
    - Conventional routing, providing E2E transport.
- Routing for data
    - Usually more efficicent than connectivity routing, since the routing directly addresses the data
    - It skips the part of E2E connectivity, which is not always necessary
- Routing for alternatives ➔ less monopoly
    - All sorts of dweb protocols route for alternatives (routes for a machine-readable problem, ie. hashes)
    - Recommenders and indices route for alternatives too (more human-readable)
    - For the same task, it is possible to route for another equally trustworthy node to perform. This is what **web-of-trust** or reputation system provides, decoupling trustworthiness from specific nodes.
- Routing for privacy ➔ anonymity


