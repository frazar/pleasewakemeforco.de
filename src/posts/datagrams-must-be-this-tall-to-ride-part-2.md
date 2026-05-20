
# Drafting possible solutions

To summarize the above findings, my issue is that IP datagrams sent from my ADSL
router to the Internet are outright dropped if their size matches one of the
"cursed" sizes.

TODO: Add diagram of issue

How to address the issue?

One possibility is to perform some packet manipulation on outbound packets to
change their size and save the from a terrible destiny.

- I first come up with the idea of reducing the size of the "cursed" packets by
  applying IP fragmentation. This is quite simple to implement, the
  fragmentation feature that is already available in IP. Additionally, if the
  source host fragments the IP packets it sends, the destination host will
  automatically recombine the fragments.

  I managed to implement the first approach, and I was even able to make the
  `ping` requests work. However, the are some situations where packets are not
  allowed to be fragmented (for example, TCP packets used in TLS handshakes can
  not be fragmented for security concerns).

- If reducing the packet size is not possible, then what about increasing it?

  An IPv4 packet is composed of:

  - an IPv4 header,
  - an IPv4 payload.

Unfortunately, the size of the IPv4 payload can not be   increased without also
  affecting how the inner Layer 3 packets are parsed.

On the other hand, the IPv4 header size is not fixed! The   IPv4 standard allows
the IP header to have a variable number of "options",   whose size can range from
  0 to 40 bytes with steps of 4 bytes.

![](./datagrams-must-be-this-tall-to-ride/90-ipv4-packet-structure-light.svg#only-light){ loading=lazy width=50% style='margin-left: auto; margin-right: auto; width: 80%; max-width: 800px' }
![](./datagrams-must-be-this-tall-to-ride/90-ipv4-packet-structure-dark.svg#only-dark){ loading=lazy width=50% style='margin-left: auto; margin-right: auto; width: 80%; max-width: 800px; opacity: 0.82' }
/// caption
By Michel Bakni - Postel, J. (September 1981) RFC 791, IP Protocol, DARPA Internet Program Protocol Specification, p. 1 DOI: 10.17487/RFC0791, CC BY-SA 4.0, https://commons.wikimedia.org/w/index.php?curid=79949694
///

So a possibility is to add a sufficient number of IP header options so that the
overall IP datagram size does not match any of the cursed sizes.
Unfortunately, IP header options are rarely used in the general Internet and intermediate routers often drop IPv4 packets specifying options.

# Packet inflater

# Packet shrinker

## Conclusions

- Maingau Energie sucks

Follow-up work:

- Use eBPF instead
- extend to IPv6