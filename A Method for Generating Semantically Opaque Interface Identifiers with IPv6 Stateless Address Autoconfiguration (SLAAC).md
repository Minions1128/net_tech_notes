# A Method for Generating Semantically Opaque Interface Identifiers with IPv6 Stateless Address Autoconfiguration (SLAAC)

## Abstract

This document specifies a method for generating IPv6 Interface Identifiers to be used with IPv6 Stateless Address Autoconfiguration (SLAAC), such that an IPv6 address configured using this method is stable within each subnet, but the corresponding Interface Identifier changes when the host moves from one network to another.  This method is meant to be an alternative to generating Interface Identifiers based on hardware addresses (e.g., IEEE LAN Media Access Control (MAC) addresses), such that the benefits of stable addresses can be achieved without sacrificing the security and privacy of users.  The ethod specified in this document applies to all prefixes a host may be employing, including link-local, global, and unique-local prefixes (and their corresponding addresses).

## 1. Introduction

[RFC4862] specifies Stateless Address Autoconfiguration (SLAAC) for IPv6 [RFC2460], which typically results in hosts configuring one or more "stable" addresses composed of a network prefix advertised by a local router, and an Interface Identifier (IID) that typically embeds a hardware address (e.g., an IEEE LAN MAC address) [RFC4291]. Cryptographically Generated Addresses (CGAs) [RFC3972] are yet another method for generating Interface Identifiers; CGAs bind a public signature key to an IPv6 address in the SEcure Neighbor Discovery (SEND) [RFC3971] protocol.

Generally, the traditional SLAAC addresses are thought to simplify network management, since they simplify Access Control Lists (ACLs) and logging.  However, they have a number of drawbacks:

- Since the resulting Interface Identifiers do not vary over time, they allow correlation of host activities within the same network, thus negatively affecting the privacy of users (see [ADDR-GEN-PRIVACY] and [IAB-PRIVACY]).

- Since the resulting Interface Identifiers are constant across networks, the resulting IPv6 addresses can be leveraged to track and correlate the activity of a host across multiple networks (e.g., track and correlate the activities of a typical client connecting to the public Internet from different locations), thus negatively affecting the privacy of users.

- Since embedding the underlying link-layer address in the Interface Identifier will result in specific address patterns, such patterns may be leveraged by attackers to reduce the search space when performing address-scanning attacks [IPV6-RECON]. For example, the IPv6 addresses of all hosts manufactured by the same vendor (within a given time frame) will likely contain the same IEEE Organizationally Unique Identifier (OUI) in the Interface Identifier.

- Embedding the underlying hardware address in the Interface Identifier leaks device-specific information that could be leveraged to launch device-specific attacks.

- Embedding the underlying link-layer address in the Interface Identifier means that replacement of the underlying interface hardware will result in a change of the IPv6 address(es) assigned to that interface.

[ADDR-GEN-PRIVACY] provides additional details regarding how the aforementioned vulnerabilities could be exploited and the extent to which the method discussed in this document mitigates them.
```

```
   The "Privacy Extensions for Stateless Address Autoconfiguration in
   IPv6" [RFC4941] (henceforth referred to as "temporary addresses")
   were introduced to complicate the task of eavesdroppers and other
   information collectors (e.g., IPv6 addresses in web server logs or
   email headers, etc.) to correlate the activities of a host, and
   basically result in temporary (and random) Interface Identifiers.
   These temporary addresses are generated in addition to the
   traditional IPv6 addresses based on IEEE LAN MAC addresses, with the
   temporary addresses being employed for "outgoing communications", and
   the traditional SLAAC addresses being employed for "server" functions
   (i.e., receiving incoming connections).

   It should be noted that temporary addresses can be challenging in a
   number of areas.  For example, from a network-management point of
   view, they tend to increase the complexity of event logging,
   troubleshooting, enforcement of access controls, and quality of
   service, etc.  As a result, some organizations disable the use of
   temporary addresses even at the expense of reduced privacy
   [BROERSMA].  Temporary addresses may also result in increased
   implementation complexity, which might not be possible or desirable
   in some implementations (e.g., some embedded devices).

   In scenarios in which temporary addresses are deliberately not used
   (possibly for any of the aforementioned reasons), all a host is left
   with is the stable addresses that have typically been generated from
   the underlying hardware addresses.  In such scenarios, it may still
   be desirable to have addresses that mitigate address-scanning attacks
   and that, at the very least, do not reveal the host's identity when
   roaming from one network to another -- without complicating the
   operation of the corresponding networks.

   However, even with temporary addresses in place, a number of issues
   remain to be mitigated.  Namely,

   - since temporary addresses [RFC4941] do not eliminate the use of
      fixed identifiers for server-like functions, they only partially
      mitigate host-tracking and activity correlation across networks
      (see [ADDR-GEN-PRIVACY] for some example attacks that are still
      possible with temporary addresses).

   - since temporary addresses [RFC4941] do not replace the traditional
      SLAAC addresses, an attacker can still leverage patterns in SLAAC
      addresses to greatly reduce the search space for "alive" nodes
      [GONT-DEEPSEC2011] [CPNI-IPV6] [IPV6-RECON].



Gont                         Standards Track                    [Page 4]

RFC 7217            Stable and Opaque IIDs with SLAAC         April 2014


   Hence, there is a motivation to improve the properties of "stable"
   addresses regardless of whether or not temporary addresses are
   employed.

   This document specifies a method to generate Interface Identifiers
   that are stable for each network interface within each subnet, but
   that change as a host moves from one network to another.  Thus, this
   method enables keeping the "stability" properties of the Interface
   Identifiers specified in [RFC4291], while still mitigating address-
   scanning attacks and preventing correlation of the activities of a
   host as it moves from one network to another.

2.  Terminology

   The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
   "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
   document are to be interpreted as described in [RFC2119].

3.  Relationship to Other Standards

   The method specified in this document is orthogonal to the use of
   temporary addresses [RFC4941], since it is meant to improve the
   security and privacy properties of the stable addresses that are
   employed along with the aforementioned temporary addresses.  In
   scenarios in which temporary addresses are employed, implementation
   of the mechanism described in this document (in replacement of stable
   addresses based on, e.g., IEEE LAN MAC addresses) will mitigate
   address-scanning attacks and also mitigate the remaining vectors for
   correlating host activities based on the host's constant (i.e.,
   stable across networks) Interface Identifiers.  On the other hand,
   for hosts that currently disable temporary addresses [RFC4941],
   implementation of this mechanism would mitigate the host-tracking and
   address-scanning issues discussed in Section 1.

   While the method specified in this document is meant to be used with
   SLAAC, this does not preclude this algorithm from being used with
   other address configuration mechanisms, such as DHCPv6 [RFC3315] or
   manual address configuration.













Gont                         Standards Track                    [Page 5]

RFC 7217            Stable and Opaque IIDs with SLAAC         April 2014


4.  Design Goals

   This document specifies a method for generating Interface Identifiers
   to be used with IPv6 SLAAC, with the following goals:

   - The resulting Interface Identifiers remain stable for each prefix
      used with SLAAC within each subnet for the same network interface.
      That is, the algorithm generates the same Interface Identifier
      when configuring an address (for the same interface) belonging to
      the same prefix within the same subnet.

   - The resulting Interface Identifiers must change when addresses are
      configured for different prefixes.  That is, if different
      autoconfiguration prefixes are used to configure addresses for the
      same network interface card, the resulting Interface Identifiers
      must be (statistically) different.  This means that, given two
      addresses produced by the method specified in this document, it
      must be difficult for an attacker to tell whether the addresses
      have been generated by the same host.

   - It must be difficult for an outsider to predict the Interface
      Identifiers that will be generated by the algorithm, even with
      knowledge of the Interface Identifiers generated for configuring
      other addresses.

   - Depending on the specific implementation approach (see Section 5
      and Appendix A), the resulting Interface Identifiers may be
      independent of the underlying hardware (e.g., IEEE LAN MAC
      address).  For example, this means that replacing a Network
      Interface Card (NIC) or adding links dynamically to a Link
      Aggregation Group (LAG) will not have the (generally undesirable)
      effect of changing the IPv6 addresses used for that network
      interface.

   - The method specified in this document is meant to be an
      alternative to producing IPv6 addresses based on hardware
      addresses (e.g., IEEE LAN MAC addresses, as specified in
      [RFC2464]).  That is, this document does not formally obsolete or
      deprecate any of the existing algorithms to generate Interface
      Identifiers.  It is meant to be employed for all of the stable
      (i.e., non-temporary) IPv6 addresses configured with SLAAC for a
      given interface, including global, link-local, and unique-local
      IPv6 addresses.

   We note that this method is incrementally deployable, since it does
   not pose any interoperability implications when deployed on networks
   where other nodes do not implement or employ it.  Additionally, we
   note that this document does not update or modify IPv6 Stateless



Gont                         Standards Track                    [Page 6]

RFC 7217            Stable and Opaque IIDs with SLAAC         April 2014


   Address Autoconfiguration (SLAAC) [RFC4862] itself, but rather it
   only specifies an alternative algorithm to generate Interface
   Identifiers.  Therefore, the usual address lifetime properties (as
   specified in the corresponding Prefix Information Options) apply when
   IPv6 addresses are generated as a result of employing the algorithm
   specified in this document with SLAAC [RFC4862].  Additionally, from
   the point of view of renumbering, we note that these addresses behave
   like the traditional IPv6 addresses (that embed a hardware address)
   resulting from SLAAC [RFC4862].

5.  Algorithm Specification

   IPv6 implementations conforming to this specification MUST generate
   Interface Identifiers using the algorithm specified in this section
   as a replacement for any other algorithms for generating "stable"
   addresses with SLAAC (such as those specified in [RFC2464],
   [RFC2467], and [RFC2470]).  However, implementations conforming to
   this specification MAY employ the algorithm specified in [RFC4941] to
   generate temporary addresses in addition to the addresses generated
   with the algorithm specified in this document.  The method specified
   in this document MUST be employed for generating the Interface
   Identifiers with SLAAC for all the stable addresses, including IPv6
   global, link-local, and unique-local addresses.

   Implementations conforming to this specification SHOULD provide the
   means for a system administrator to enable or disable the use of this
   algorithm for generating Interface Identifiers.

   Unless otherwise noted, all of the parameters included in the
   expression below MUST be included when generating an Interface
   Identifier.

   1.  Compute a random (but stable) identifier with the expression:

       RID = F(Prefix, Net_Iface, Network_ID, DAD_Counter, secret_key)

       Where:

       RID:
          Random (but stable) Identifier

       F():
          A pseudorandom function (PRF) that MUST NOT be computable from
          the outside (without knowledge of the secret key).  F() MUST
          also be difficult to reverse, such that it resists attempts to
          obtain the secret_key, even when given samples of the output
          of F() and knowledge or control of the other input parameters.
          F() SHOULD produce an output of at least 64 bits.  F() could



Gont                         Standards Track                    [Page 7]

RFC 7217            Stable and Opaque IIDs with SLAAC         April 2014


          be implemented as a cryptographic hash of the concatenation of
          each of the function parameters.  SHA-1 [FIPS-SHS] and SHA-256
          are two possible options for F().  Note: MD5 [RFC1321] is
          considered unacceptable for F() [RFC6151].

       Prefix:
          The prefix to be used for SLAAC, as learned from an ICMPv6
          Router Advertisement message, or the link-local IPv6 unicast
          prefix [RFC4291].

       Net_Iface:
          An implementation-dependent stable identifier associated with
          the network interface for which the RID is being generated.
          An implementation MAY provide a configuration option to select
          the source of the identifier to be used for the Net_Iface
          parameter.  A discussion of possible sources for this value
          (along with the corresponding trade-offs) can be found in
          Appendix A.

       Network_ID:
          Some network-specific data that identifies the subnet to which
          this interface is attached -- for example, the IEEE 802.11
          Service Set Identifier (SSID) corresponding to the network to
          which this interface is associated.  Additionally, Simple DNA
          [RFC6059] describes ideas that could be leveraged to generate
          a Network_ID parameter.  This parameter is OPTIONAL.

       DAD_Counter:
          A counter that is employed to resolve Duplicate Address
          Detection (DAD) conflicts.  It MUST be initialized to 0, and
          incremented by 1 for each new tentative address that is
          configured as a result of a DAD conflict.  Implementations
          that record DAD_Counter in non-volatile memory for each
          {Prefix, Net_Iface, Network_ID} tuple MUST initialize
          DAD_Counter to the recorded value if such an entry exists in
          non-volatile memory.  See Section 6 for additional details.

       secret_key:
          A secret key that is not known by the attacker.  The secret
          key SHOULD be of at least 128 bits.  It MUST be initialized to
          a pseudo-random number (see [RFC4086] for randomness
          requirements for security) when the operating system is
          installed or when the IPv6 protocol stack is "bootstrapped"
          for the first time.  An implementation MAY provide the means
          for the system administrator to display and change the secret
          key.





Gont                         Standards Track                    [Page 8]

RFC 7217            Stable and Opaque IIDs with SLAAC         April 2014


   2.  The Interface Identifier is finally obtained by taking as many
       bits from the RID value (computed in the previous step) as
       necessary, starting from the least significant bit.

          We note that [RFC4291] requires that the Interface IDs of all
          unicast addresses (except those that start with the binary
          value 000) be 64 bits long.  However, the method discussed in
          this document could be employed for generating Interface IDs
          of any arbitrary length, albeit at the expense of reduced
          entropy (when employing Interface IDs smaller than 64 bits).

       The resulting Interface Identifier SHOULD be compared against the
       reserved IPv6 Interface Identifiers [RFC5453] [IANA-RESERVED-IID]
       and against those Interface Identifiers already employed in an
       address of the same network interface and the same network
       prefix.  In the event that an unacceptable identifier has been
       generated, this situation SHOULD be handled in the same way as
       the case of duplicate addresses (see Section 6).

   This document does not require the use of any specific PRF for the
   function F() above, since the choice of such PRF is usually a trade-
   off between a number of properties (processing requirements, ease of
   implementation, possible intellectual property rights, etc.), and
   since the best possible choice for F() might be different for
   different types of devices (e.g., embedded systems vs. regular
   servers) and might possibly change over time.

   Including the SLAAC prefix in the PRF computation causes the
   Interface Identifier to vary across each prefix (link-local, global,
   etc.) employed by the host and, consequently, also across networks.
   This mitigates the correlation of activities of multihomed hosts
   (since each of the corresponding addresses will typically employ a
   different prefix), host-tracking (since the network prefix will
   change as the host moves from one network to another), and any other
   attacks that benefit from predictable Interface Identifiers (such as
   IPv6 address-scanning attacks).

   The Net_Iface is a value that identifies the network interface for
   which an IPv6 address is being generated.  The following properties
   are required for the Net_Iface parameter:

   - It MUST be constant across system bootstrap sequences and other
      network events (e.g., bringing another interface up or down).

   - It MUST be different for each network interface simultaneously in
      use.





Gont                         Standards Track                    [Page 9]

RFC 7217            Stable and Opaque IIDs with SLAAC         April 2014


   Since the stability of the addresses generated with this method
   relies on the stability of all arguments of F(), it is key that the
   Net_Iface parameter be constant across system bootstrap sequences and
   other network events.  Additionally, the Net_Iface parameter must
   uniquely identify an interface within the host, such that two
   interfaces connecting to the same network do not result in duplicate
   addresses.  Different types of operating systems might benefit from
   different stability properties of the Net_Iface parameter.  For
   example, a client-oriented operating system might want to employ
   Net_Iface identifiers that are attached to the NIC, such that a
   removable NIC always gets the same IPv6 address, irrespective of the
   system communications port to which it is attached.  On the other
   hand, a server-oriented operating system might prefer Net_Iface
   identifiers that are attached to system slots/ports, such that
   replacement of a NIC does not result in an IPv6 address change.
   Appendix A discusses possible sources for the Net_Iface along with
   their pros and cons.

   Including the optional Network_ID parameter when computing the RID
   value above causes the algorithm to produce a different Interface
   Identifier when connecting to different networks, even when
   configuring addresses belonging to the same prefix.  This means that
   a host would employ a different Interface Identifier as it moves from
   one network to another even for IPv6 link-local addresses or Unique
   Local Addresses (ULAs) [RFC4193].  In those scenarios where the
   Network_ID is unknown to the attacker, including this parameter might
   help mitigate attacks where a victim host connects to the same subnet
   as the attacker and the attacker tries to learn the Interface
   Identifier used by the victim host for a remote network (see
   Section 8 for further details).

   The DAD_Counter parameter provides the means to intentionally cause
   this algorithm to produce different IPv6 addresses (all other
   parameters being the same).  This could be necessary to resolve DAD
   conflicts, as discussed in detail in Section 6.

   Note that the result of F() in the algorithm above is no more secure
   than the secret key.  If an attacker is aware of the PRF that is
   being used by the victim (which we should expect), and the attacker
   can obtain enough material (i.e., addresses configured by the
   victim), the attacker may simply search the entire secret-key space
   to find matches.  To protect against this, key lengths of at least
   128 bits should be adequate.  The secret key is initialized at system
   installation time to a pseudorandom number, thus allowing this
   mechanism to be enabled and used automatically, without user
   intervention.  Providing a mechanism to display and change the
   secret_key would allow an administrator to cause a new/replacement
   system (with the same implementation of this specification) to



Gont                         Standards Track                   [Page 10]

RFC 7217            Stable and Opaque IIDs with SLAAC         April 2014


   generate the same IPv6 addresses as the system being replaced.  We
   note that since the privacy of the scheme specified in this document
   relies on the secrecy of the secret_key parameter, implementations
   should constrain access to the secret_key parameter to the extent
   practicable (e.g., require superuser privileges to access it).
   Furthermore, in order to prevent leakages of the secret_key
   parameter, it should not be used for any purposes other than being a
   parameter to the scheme specified in this document.

   We note that all of the bits in the resulting Interface IDs are
   treated as "opaque" bits [RFC7136].  For example, the universal/local
   bit of Modified EUI-64 format identifiers is treated as any other bit
   of such an identifier.  In theory, this might result in IPv6 address
   collisions and DAD failures that would otherwise not be encountered.
   However, this is not deemed as a likely issue because of the
   following considerations:

   - The interface IDs of all addresses (except those of addresses that
      start with the binary value 000) are 64 bits long.  Since the
      method specified in this document results in random Interface IDs,
      the probability of DAD failures is very small.

   - Real-world data indicates that MAC address reuse is far more
      common than assumed [HD-MOORE].  This means that even IPv6
      addresses that employ (allegedly) unique identifiers (such as IEEE
      LAN MAC addresses) might result in DAD failures and, hence,
      implementations should be prepared to gracefully handle such
      occurrences.  Additionally, some virtualization technologies
      already employ hardware addresses that are randomly selected, and,
      hence, cannot be guaranteed to be unique [IPV6-RECON].

   - Since some popular and widely deployed operating systems (such as
      Microsoft Windows) do not embed hardware addresses in the
      Interface IDs of their stable addresses, reliance on such unique
      identifiers is reduced in the deployed world (fewer deployed
      systems rely on them for the avoidance of address collisions).

   Finally, we note that since different implementations are likely to
   use different values for the secret_key parameter, and may also
   employ different PRFs for F() and different sources for the Net_Iface
   parameter, the addresses generated by this scheme should not expected
   to be stable across different operating-system installations.  For
   example, a host that is dual-boot or that is reinstalled may result
   in different IPv6 addresses for each operating system and/or
   installation.






Gont                         Standards Track                   [Page 11]

RFC 7217            Stable and Opaque IIDs with SLAAC         April 2014


6.  Resolving DAD Conflicts

   If, as a result of performing DAD [RFC4862], a host finds that the
   tentative address generated with the algorithm specified in Section 5
   is a duplicate address, it SHOULD resolve the address conflict by
   trying a new tentative address as follows:

   - DAD_Counter is incremented by 1.

   - A new Interface Identifier is generated with the algorithm
      specified in Section 5, using the incremented DAD_Counter value.

   Hosts SHOULD introduce a random delay between 0 and IDGEN_DELAY
   seconds (see Section 7) before trying a new tentative address, to
   avoid lockstep behavior of multiple hosts.

   This procedure may be repeated a number of times until the address
   conflict is resolved.  Hosts SHOULD try at least IDGEN_RETRIES (see
   Section 7) tentative addresses if DAD fails for successive generated
   addresses, in the hopes of resolving the address conflict.  We also
   note that hosts MUST limit the number of tentative addresses that are
   tried (rather than indefinitely try a new tentative address until the
   conflict is resolved).

   In those unlikely scenarios in which duplicate addresses are detected
   and the order in which the conflicting hosts configure their
   addresses varies (e.g., because they may be bootstrapped in different
   orders), the algorithm specified in this section for resolving DAD
   conflicts could lead to addresses that are not stable within the same
   subnet.  In order to mitigate this potential problem, hosts MAY
   record the DAD_Counter value employed for a specific {Prefix,
   Net_Iface, Network_ID} tuple in non-volatile memory, such that the
   same DAD_Counter value is employed when configuring an address for
   the same Prefix and subnet at any other point in time.  We note that
   the use of non-volatile memory is OPTIONAL, and hosts that do not
   implement this feature are still compliant to this protocol
   specification.

   In the event that a DAD conflict cannot be solved (possibly after
   trying a number of different addresses), address configuration would
   fail.  In those scenarios, hosts MUST NOT automatically fall back to
   employing other algorithms for generating Interface Identifiers.









Gont                         Standards Track                   [Page 12]

RFC 7217            Stable and Opaque IIDs with SLAAC         April 2014


7.  Specified Constants

   This document specifies the following constant:

   IDGEN_RETRIES:
      defaults to 3.

   IDGEN_DELAY:
      defaults to 1 second.

8.  Security Considerations

   This document specifies an algorithm for generating Interface
   Identifiers to be used with IPv6 Stateless Address Autoconfiguration
   (SLAAC), as an alternative to e.g., Interface Identifiers that embed
   hardware addresses (such as those specified in [RFC2464], [RFC2467],
   and [RFC2470]).  When compared to such identifiers, the identifiers
   specified in this document have a number of advantages:

   - They prevent trivial host-tracking based on the IPv6 address,
      since when a host moves from one network to another the network
      prefix used for autoconfiguration and/or the Network ID (e.g.,
      IEEE 802.11 SSID) will typically change; hence, the resulting
      Interface Identifier will also change (see [ADDR-GEN-PRIVACY]).

   - They mitigate address-scanning techniques that leverage
      predictable Interface Identifiers (e.g., known Organizationally
      Unique Identifiers) [IPV6-RECON].

   - They may result in IPv6 addresses that are independent of the
      underlying hardware (i.e., the resulting IPv6 addresses do not
      change if a network interface card is replaced) if an appropriate
      source for Net_Iface (see Section 5) is employed.

   - They prevent the information leakage produced by embedding
      hardware addresses in the Interface Identifier (which could be
      exploited to launch device-specific attacks).

   - Since the method specified in this document will result in
      different Interface Identifiers for each configured address,
      knowledge or leakage of the Interface Identifier employed for one
      stable address will not negatively affect the security/privacy of
      other stable addresses configured for other prefixes (whether at
      the same time or at some other point in time).

   We note that while some probing techniques (such as the use of ICMPv6
   Echo Request and ICMPv6 Echo Response packets) could be mitigated by
   a personal firewall at the target host, for other probing vectors,



Gont                         Standards Track                   [Page 13]

RFC 7217            Stable and Opaque IIDs with SLAAC         April 2014


   such as listening to ICMPv6 "Destination Unreachable, Address
   Unreachable" (Type 1, Code 3) error messages that refer to the target
   addresses [IPV6-RECON], there is nothing a host can do (e.g., a
   personal firewall at the target host would not be able to mitigate
   this probing technique).  Hence, the method specified in this
   document is still of value for hosts that employ personal firewalls.

   In scenarios in which an attacker can connect to the same subnet as a
   victim host, the attacker might be able to learn the Interface
   Identifier employed by the victim host for an arbitrary prefix by
   simply sending a forged Router Advertisement [RFC4861] for that
   prefix, and subsequently learning the corresponding address
   configured by the victim host (either listening to the Duplicate
   Address Detection packets or to any other traffic that employs the
   newly configured address).  We note that a number of factors might
   limit the ability of an attacker to successfully perform such an
   attack:

   - First-Hop security mechanisms such as Router Advertisement Guard
      (RA-Guard) [RFC6105] [RFC7113] could prevent the forged Router
      Advertisement from reaching the victim host.

   - If the victim implementation includes the (optional) Network_ID
      parameter for computing F() (see Section 5), and the Network_ID
      employed by the victim for a remote network is unknown to the
      attacker, the Interface Identifier learned by the attacker would
      differ from the one used by the victim when connecting to the
      legitimate network.

   In any case, we note that at the point in which this kind of attack
   becomes a concern, a host should consider employing SEND [RFC3971] to
   prevent an attacker from illegitimately claiming authority for a
   network prefix.

   We note that this algorithm is meant to be an alternative to
   Interface Identifiers such as those specified in [RFC2464], but it is
   not meant as an alternative to temporary Interface Identifiers (such
   as those specified in [RFC4941]).  Clearly, temporary addresses may
   help to mitigate the correlation of activities of a host within the
   same network, and they may also reduce the attack exposure window
   (since temporary addresses are short-lived when compared to the
   addresses generated with the method specified in this document).  We
   note that the implementation of this specification would still
   benefit those hosts employing temporary addresses, since it would
   mitigate host-tracking vectors still present when such addresses are
   used (see [ADDR-GEN-PRIVACY]) and would also mitigate address-
   scanning techniques that leverage patterns in IPv6 addresses that
   embed IEEE LAN MAC addresses.  Finally, we note that the method



Gont                         Standards Track                   [Page 14]

RFC 7217            Stable and Opaque IIDs with SLAAC         April 2014


   described in this document addresses some of the privacy concerns
   arising from the use of IPv6 addresses that embed IEEE LAN MAC
   addresses, without the use of temporary addresses, thus possibly
   offering an interesting trade-off for those scenarios in which the
   use of temporary addresses is not feasible.

9.  Acknowledgements

The algorithm specified in this document has been inspired by Steven Bellovin's work ([RFC1948]) in the area of TCP sequence numbers.

The author would like to thank (in alphabetical order) Mikael Abrahamsson, Ran Atkinson, Karl Auer, Steven Bellovin, Matthias
   Bethke, Ben Campbell, Brian Carpenter, Tassos Chatzithomaoglou, Tim
   Chown, Alissa Cooper, Dominik Elsbroek, Stephen Farrell, Eric Gray,
   Brian Haberman, Bob Hinden, Christian Huitema, Ray Hunter, Jouni
   Korhonen, Suresh Krishnan, Eliot Lear, Jong-Hyouk Lee, Andrew
   McGregor, Thomas Narten, Simon Perreault, Tom Petch, Michael
   Richardson, Vincent Roca, Mark Smith, Hannes Frederic Sowa, Martin
   Stiemerling, Dave Thaler, Ole Troan, Lloyd Wood, James Woodyatt, and
   He Xuan, for providing valuable comments on earlier versions of this
   document.

   Hannes Frederic Sowa produced a reference implementation of this
   specification for the Linux kernel.

   Finally, the author wishes to thank Nelida Garcia and Guillermo Gont
   for their love and support.
