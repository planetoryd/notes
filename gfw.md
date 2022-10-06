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

- the list of IP addresses must be kept up-to-date
- all of the other websites that share the same IP address will also be blocked.
  - 69.8% of the websites for .com, .org and .net domains shared an IP address with 50 or more other websites.

Deep packet inspection

- Identify P2P traffic to do QoS
- Statistical, The SPID algorithm can detect the application layer protocol (layer 7) by signatures (a sequence of bytes at a particular offset in the handshake), by analyzing flow information (packet sizes, etc.) and payload statistics (how frequently the byte value occurs in order to measure entropy) from pcap files.
- Deep Learning for Encrypted Traffic Classification

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

#### Identification

> https://doi.org/10.1007/s11227-018-2268-y

> Real-time identification of three Tor pluggable
> transports using machine learning technique

Wang et al. [16] propose an approach
for recognizing tor and its obfuscates using deep analysis of payload. While their results
are promising in terms of recognition rates, the need for computationally expensive
features such as entropy of payload is a significant issue. As an alternative for DPI,
machine learning methods can be of help to identify plugins. These techniques use a
bunch of flow statistics such as mean packet size and packet inter-arrival time that are
independent of flow contents.

We present an empirical study on detection of Obfs3, **Obfs4**, and ScrambleSuit.

Another fact that Fig. 7 reveals is that detection of Obfs3 is slightly harder than
Obfs4 and ScrambleSuit. This may be attributed to the fact that Obfs3 does not alter
the underlying traffic statistics.

### Sosistab

https://github.com/geph-official/sosistab

Sosistab is an unreliable, obfuscated datagram transport over UDP and TCP. obfs4-like

### Meek bridge

> The meek protocol is also likely vulnerable to statistical attacks based on request/response timing and traffic volume as no attempts are made to mask traffic volume, and the client driven poll timing is rather distinctive.

One domain appears on the “outside” of an HTTPS request—in the DNS request and TLS Server Name Indication—while another domain appears on the “inside”—in the HTTP Host header, invisible to the censor under HTTPS encryption.

The client, intermediate web service, and destination proxy are uncontrolled by the censor.

meek is just one of several circumvention systems using domain fronting. You can read about the technique in general here.
**Psiphon** uses domain fronting in some places. It has a fork of meek-client and meek-server as well as a port of meek-client to Java for Android.
**Flashlight** from Lantern is an HTTP proxy that uses domain fronting. enproxy is a TCP-over-HTTP tunnel.
**FireFly** Proxy is a meek-like proxy implemented in Python. It is designed against the Great Firewall of China.
GoAgent

### --

https://www.bamsoftware.com/papers/fronting/#sec:threatmodel

1. Obfuscation / Avoid blacklist
   - It is expensive to distinguish it from other traffic
2. Mimicry / Exploiting whitelist
   - It is trivial to distinguish it from other traffic
   - If it fails to mimic, the outcome is catastrophic

The other strategy against DPI is the steganographic one: look like something the censor allows. fteproxy uses format-transforming encryption to encode data into strings that match a given regular expression, for example a regular-expression approximation of HTTP. StegoTorus transforms traffic to look like a cover protocol using a variety of special-purpose encoders

> address-based blocking

BridgeDB uses CAPTCHAs and other rate-limiting measures, and over short time periods, always returns the same bridges to the same requester, preventing enumeration by simple repeated queries

> The Parrot is Dead:
> Observing Unobservable Network Communications

Convincingly mimicking a sophisticated distributed system like Skype, with
multiple, inter-dependent sub-protocols and correlations, is
an insurmountable challenge. To win, the censor needs only
to find a few discrepancies, while the parrot must satisfy a
daunting list of imitation requirements.

They (China) also enumerated and blocked all bridge IP addresses provided via
Gmail, leaving Tor with only the social network distribution
strategy and private bridge

Furthermore, Iran
repeatedly blocks all encrypted traffic.

Censors can even unplug an entire country from the
Internet, as in Egypt and Libya.

One promising alternative is to not mimic, but **run the
actual protocol**, i.e., move the hidden content higher in
the protocol stack. For example, FreeWave [28] hides data
in encrypted voice or video payloads sent over genuine
Skype, while SWEET [29] embeds it in email messages.

This is called **Tunneling** in *MultiProxy: a collaborative approach to censorship
circumvention* 

> https://www.bamsoftware.com/papers/fronting/
>
> https://repository.tudelft.nl/islandora/object/uuid:858f16c9-71f1-4d7f-8baf-d4fa0a0687e3/datastream/OBJ/download

# On GFW policy-making

- Why don't they adopt a harsher policy or just whitelist.
  - They censor carefully, using probing, instead of banning on sight
- The policy is to censor carefully. Will it be changed ?
