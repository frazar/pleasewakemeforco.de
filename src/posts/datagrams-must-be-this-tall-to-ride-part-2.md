---
date: 2026/10/29
title: Datagrams must be this tall to ride (Part 2)
previous_page:
    url: posts/how-to-fix-soft-bricked-fritzbox-7530-after-openwrt-install
    title: How to fix a soft-bricked FritzBox 7530 after installing OpenWrt
---

_The finale of the post series about tall datagrams._

**TODO: write image**

??? info "This post is part of a series"

    > 1. [Datagrams must be this tall to ride (Part 1)](./datagrams-must-be-this-tall-to-ride-part-1.md)
    2.
    > 2. [How to fix a soft-bricked FritzBox 7530 after installing OpenWrt](./how-to-fix-soft-bricked-fritzbox-7530-after-openwrt-install.md)
    > 3. (this post)

## Problem statement

In [the previous posts](./datagrams-must-be-this-tall-to-ride-part-1.md) in this
series, I blabbered about I started having Internet connection problems after
switching to a new Internet Service Provider (ISP). After much investigation, it
turns out that IP datagrams outgoing from my router where inexplicably dropped
if their size is 35 bytes. Or 97 bytes. Or any of the 178 sizes that I was able
to identify to as "cursed" sizes.

<div class="inline-svg">
--8<-- "posts/datagrams-must-be-this-tall-to-ride-part-2/10-problem-statement.svg"
</div>

At this point, I do not know _why_ these specific sizes where cursed, but at
least I know _which_ ones are cursed. So maybe I can do something about it?

## The plan

The plan is to manipulate IP datagrams outgoing from my ADSL router so that none
of these datagrams has a cursed size anymore. In this way, none of them will get
dropped!

But what kind of manipulation? Well, size is a one dimensional variable, meaning
it can either go down or up. Let's consider down first.

To reduce the size of a datagram without losing information, one can force IP
fragmentation. Fragmentation is an IP feature where a datagram is split into
smaller pieces to allow it to traverse a network whose Maximum Transmission Unit
(MTU) is smaller than the datagram itself. Since fragmentation is a built-in
feature of IP, the destination server is capable of recomposing the fragments at
its end. Unfortunately, applications can disable IP fragmentation by enabling
the `Don't Fragment` bit on their datagrams. By inspecting Wireshark captures,
it turns out that is often the case.

So, if the size can not be decreased, what about increasing it?

Simply padding the IP datagram with zeros wouldn't work, because it would mess
up the payload that is passed up to higher-level ISO abstractions. However, an
IPv4 datagram is not just its payload. Looking at at the IPv4 specification, one
can spot a part of the datagram that has _variable_ length.

<div class="inline-svg">
--8<-- "posts/datagrams-must-be-this-tall-to-ride-part-2/15-ipv4-datagram-layout.svg"
</div>

The IPv4 options! An IPv4 datagram can optionally (ha!) include an option
section, where the source host (or an intermediate router router) can encode
without affecting higher-level ISO abstractions. The main constraints on the
length of the IPv4 options are the following:

- the length of the options must be between 0 and 40 bytes
- the length of the options must be a multiple of 4 bytes.

There is plenty of room for me to play with! A quick check shows that all the
cursed datagram sizes are within 40 bytes of a working datagram size that is
also a multiple of 4.

As for the content of the option header itself, you may find the complete list
of valid options [here](https://www.iana.org/assignments/ip-parameters). The
most relevant option is "End of Option List" (EOOL), whose definition can be
found in [RFC 791](https://www.rfc-editor.org/info/rfc791/#page-16). It is also
reported next in the beauty of its original ASCII-art form.

```
End of Option List

  +--------+
  |00000000|
  +--------+
    Type=0

  This option indicates the end of the option list.  This might
  not coincide with the end of the internet header according to
  the internet header length.  This is used at the end of all
  options, not the end of each option, and need only be used if
  the end of the options would not otherwise coincide with the end
  of the internet header.

  May be copied, introduced, or deleted on fragmentation, or for
  any other reason.
```

The RFC authors even had the foresight to include that last sentence ("_May be
[...] introduced [...] for any other reason_"), which definitely covers my use
case here.

Given these findings, the idea is to introduce some kind of
datagram-manipulating software on my router. Let's call it Packet[^1] Inflater.

<div class="inline-svg">
--8<-- "posts/datagrams-must-be-this-tall-to-ride-part-2/20-solution-packet-inflater-only.svg"
</div>

Packet Inflater will inspect all IPv4 datagrams sent by my router towards the
Internet. Whenever it spots an outbound packet with a cursed size, it will keep
adding EOOL options to its header until the curse if lifted[^1].

Done, right?

Well not quite. You see, IPv4 options nowadays are not considered that useful.
Actually, there are a hindrance, because networking equipment needs to slow down
packet processing to read those options and figure out what to do with them. As
a result, options are considered a red flag and packets that specify them are
simply dropped[^3].

So, I'm going to need one more piece of software called Packet Shrinker. This
software will run on another server under my control, which will strip the
options for all packets and then forward them to their actual destination. In
practice, it will act as an "exit node".

<div class="inline-svg">
--8<-- "posts/datagrams-must-be-this-tall-to-ride-part-2/30-solution-full-chain.svg"
</div>

To make sure the packets are not dropped while on their way to the exit node, my
router and the exit node will communicate through a secure encapsulate protocol
(wireguard). The encapsulation overhead will need to be considered by Packet
Inflater when deciding how many options to add to a packet.

## The implementation

## Epilogue

??? info "This post is part of a series"

    > 1. [Datagrams must be this tall to ride (Part 1)](./datagrams-must-be-this-tall-to-ride-part-1.md)
    2.
    > 2. [How to fix a soft-bricked FritPzBox 7530 after installing OpenWrt](./how-to-fix-soft-bricked-fritzbox-7530-after-openwrt-install.md)
    > 3. (this post)

[^1]:
    Since this software lifts the curse, maybe I should have called it Packet
    Shaman? Packet Exorcist?

[^3]:
    R. Fonseca, G. M. Porter, R. H. Katz, S. Shenker, and I. Stoica. IP options are
    not an option. Technical Report UCB/EECS-2005-24, EECS Department,
    University of California, Berkeley, Dec 2005. Available: [https://www.academia.edu/download/45925014/ICSI_ipoptionsare05.pdf](https://www.academia.edu/download/45925014/ICSI_ipoptionsare05.pdf)
