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

Packet Dropping - Firstly, the list of IP addresses must be kept up-to-date - all of the other websites that share the same IP address will also be blocked. - 69.8% of the websites for .com, .org and .net domains shared an IP address with 50 or more other websites.

Deep packet inspection

- Identify P2P to do QoS
- Statistical, The SPID algorithm can detect the application layer protocol (layer 7) by signatures (a sequence of bytes at a particular offset in the handshake), by analyzing flow information (packet sizes, etc.) and payload statistics (how frequently the byte value occurs in order to measure entropy) from pcap files.

# TLS

> Server Name Indication (SNI) is an extension to the Transport Layer Security (TLS) computer networking protocol by which a client indicates which hostname it is attempting to connect to at the start of the handshaking process

> Encrypted Client Hello (ECH) is a TLS 1.3 protocol extension that enables encryption of the whole Client Hello message, which is sent during the early stage of TLS 1.3 negotiation. ECH encrypts the payload with a public key that the relying party (a web browser) needs to know in advance, which means ECH is most effective with large CDNs known to browser vendors in advance.

https://stackoverflow.com/questions/2146863/how-much-data-is-leaked-from-ssl-connection

> HTTPS is vulnerable when applied to publicly-available static content. The entire site can be indexed using a web crawler, and the URI of the encrypted resource can be inferred by knowing only the intercepted request/response size.

# Obfs series

https://github.com/NullHypothesis/obfsproxy/tree/master/doc

obfs2

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

obfs3