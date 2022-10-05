walkthrough

# 2012, 2006

- Blocking Tor https://www.usenix.org/system/files/conference/foci12/foci12-final2.pdf
  - Public IPs of Tor were collected and blocked
  - deep packet inspection (DPI) boxes identify the Tor protocol
  - active scanning via Tor connection -> block
  - didn't do packet reassembly
  - obfs2 worked
    - https://github.com/NullHypothesis/obfsproxy/blob/master/doc/obfs2/obfs2-protocol-spec.txt
- RST https://pages.cs.wisc.edu/~rist/642-fall-2012/chinafirewall.pdf

Packet Dropping

- Firstly, the list of IP addresses must be kept up-to-date
  - all of the other websites that share the same IP address will also be blocked.
  - 69.8% of the websites for .com, .org and .net domains shared an IP address with 50 or more other websites.

Deep packet inspection

- Identify P2P to do QoS
- Statistical, The SPID algorithm can detect the application layer protocol (layer 7) by signatures (a sequence of bytes at a particular offset in the handshake), by analyzing flow information (packet sizes, etc.) and payload statistics (how frequently the byte value occurs in order to measure entropy) from pcap files.

# TLS

> Server Name Indication (SNI) is an extension to the Transport Layer Security (TLS) computer networking protocol by which a client indicates which hostname it is attempting to connect to at the start of the handshaking process

> Encrypted Client Hello (ECH) is a TLS 1.3 protocol extension that enables encryption of the whole Client Hello message, which is sent during the early stage of TLS 1.3 negotiation. ECH encrypts the payload with a public key that the relying party (a web browser) needs to know in advance, which means ECH is most effective with large CDNs known to browser vendors in advance.

https://stackoverflow.com/questions/2146863/how-much-data-is-leaked-from-ssl-connection

> HTTPS is vulnerable when applied to publicly-available static content. The entire site can be indexed using a web crawler, and the URI of the encrypted resource can be inferred by knowing only the intercepted request/response size.

# Pluggable Transports

https://github.com/NullHypothesis/obfsproxy/tree/master/doc

### obfs2

- exchange seeds -> decrypt & match -> ..
- a censor with limited per-connection resources

obfs2 attempts to counter the above attack by removing content signatures from network traffic. obfs2 encrypts the traffic stream with a stream cipher, which results in the traffic looking uniformly random.

obfs2 does not try to protect against non-content protocol
fingerprints, like the packet size or timing.

obfs2 (in its default configuration) does not try to protect against
Deep Packet Inspection machines that expect the obfs2 protocol and
have the resources to run it. Such machines can trivially retrieve
the decryption key off the traffic stream and use it to decrypt obfs2
and detect the Tor protocol.

### obfs3

- UniformDH pubkeys, indistinguishable from random strings of the same size
  - DH pubkeys are not
- exchange pubkeys -> padding randomness, PADLEN in [0, MAX_PADDING/2] -> padding randomness -> find & match magic hmac -> AES-CTR-128 encrypted traffic
- protection against passive Deep Packet Inspection

ScrambleSuit

Its entire payload is computationally
indistinguishable from randomness, it modifies its **flow signature** to foil
simple statistical classifiers and it employs authenticated encryption to
disguise the transported protocol.

- Pre-shared secret
- Auth
  1. redeeming a session ticket
  2. UniformDH handshake

In particular, the packet length
distribution and the distribution of inter-arrival times are modified.

While unbroken, most if not all of the functionality is also present in the obfs4 protocol, and thus is considered deprecated and has been evaluated as a historical reference only.

The ScrambleSuit protocol requires that the client proves to the server that it knows a public key belonging to the server before the server will respond with any traffic, and thus is immune to active probing attacks.

ScrambleSuit like the existing obfs3 protocol uses UniformDH for the
cryptographic handshake, which has severe performance implications due to
modular exponentiation being a expensive operation. Additionally, the key
exchange is not authenticated so **it is possible for active attackers to
mount a man in the middle attack assuming they know the client/bridge
shared secret (k_B).**

### Obfs4

Ephemeral publickeys, HMAC, ntor auth

Expected adversaries

- passive Deep Packet Inspection machines
  that expect the obfs4 protocol
- active attackers who have obtained the server's Node ID and identity public key, attempting to probe for obfs4 servers

Such machines should not be able to verify the existence
of an obfs4 server without obtaining the server's Node ID and identity
public key.

> the client proves to the server that it knows a public key belonging to the server

There are moderate attempts to obfuscate traffic volume, and the capability to **obfuscate timing related information**, however the latter is **disabled** in the default configuration as such attacks are believed to be expensive for the censor to mount, and the obfuscation adds a non-trivial amount of overhead.

Guarantees

- Obfuscate non-content protocol fingerprints, packet size, timing
- Integrity, Confidentiality

Elligator

- elliptic-curve points are encoded so
  as to be indistinguishable from uniform random string

ntor handshake

> Anonymity and one-way authentication in key exchange protocols

The server authenticates itself (knowing the privatekey) and both derive a shared key.

With improved performance.

A client with an ephemeral keypair, and a server with a long-term keypair and an ephemeral keypair

### Meek bridge

> The meek protocol is also likely vulnerable to statistical attacks based on request/response timing and traffic volume as no attempts are made to mask traffic volume, and the client driven poll timing is rather distinctive.

One domain appears on the “outside” of an HTTPS request—in the DNS request and TLS Server Name Indication—while another domain appears on the “inside”—in the HTTP Host header, invisible to the censor under HTTPS encryption.

The client, intermediate web service, and destination proxy are uncontrolled by the censor.

### --

https://www.bamsoftware.com/papers/fronting/#sec:threatmodel

The other strategy against DPI is the steganographic one: look like something the censor allows. fteproxy uses format-transforming encryption to encode data into strings that match a given regular expression, for example a regular-expression approximation of HTTP. StegoTorus transforms traffic to look like a cover protocol using a variety of special-purpose encoders

> address-based blocking

BridgeDB uses CAPTCHAs and other rate-limiting measures, and over short time periods, always returns the same bridges to the same requester, preventing enumeration by simple repeated queries

# On GFW policy-making

- Why don't they adopt a harsher policy or just whitelist.
  - They censor carefully, using probing, instead of banning on sight
- The policy is to censor carefully. Will it be changed ?
