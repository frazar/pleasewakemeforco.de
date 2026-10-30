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
series, I blabbered about how my Internet connection stopped working properly
after changing my Internet Service Provider (ISP). After much investigation, it
turns out that IP datagrams outgoing from my router where inexplicably dropped
if their size is 35 bytes. Or 97 bytes. Or any of the 178 sizes that I was able
to identify to as "cursed" sizes.

<div class="inline-svg">
--8<-- "posts/datagrams-must-be-this-tall-to-ride-part-2/10-problem-statement.svg"
</div>

At this point, I do not know _why_ these specific sizes where cursed, but at
least I know _which_ ones are cursed. So maybe I can do something about it?

## The plan

Ok, hear me out. The plan is to manipulate IP datagrams outgoing from my ADSL
router so that none of these datagrams has a cursed size. In this way, none of
them should get dropped!

But what kind of manipulation could be implemented? Well, size is a 1D variable,
meaning it either go up or down.

At first, I thought of forcing IP fragmentation. Fragmentation is an IP
feature where a datagram is split into smaller pieces to allow it to traverse
a network whose Maximum Transmission Unit (MTU) is smaller than the datagram
itself. Since fragmentation is a built-in feature of IP, the destination
server would be definitely willing to recompose the fragments at its end.
Unfortunately, applications can disable IP fragmentation by enabling the
`Don't Fragment` bit. Apparently, this is often the case.

So, if the size can not be decrease, what about increasing it? Simply padding
the IP datagram with zeros wouldn't work, because this would alter the
information on the size of the encapsulated packet is passed up to higher-level
OSI abstractions. But an IPv4 datagram also includes a _variable_ length header.

<div class="inline-svg">
--8<-- "posts/datagrams-must-be-this-tall-to-ride-part-2/15-ipv4-datagram-layout.svg"
</div>

Of course, such operation is only applied if
a datagram has one of the cursed sizes. To do so, I intend to setup some kind of
datagram-manipulating software that I'll call "packet inflater".

<div class="inline-svg">
--8<-- "posts/datagrams-must-be-this-tall-to-ride-part-2/20-solution-packet-inflater-only.svg"
</div>

At first, I attempted to

But how to inflate the packet size?

<div class="inline-svg">
--8<-- "posts/datagrams-must-be-this-tall-to-ride-part-2/30-solution-full-chain.svg"
</div>

## The implementation

## Epilogue

??? info "This post is part of a series"

    > 1. [Datagrams must be this tall to ride (Part 1)](./datagrams-must-be-this-tall-to-ride-part-1.md)
    2.
    > 2. [How to fix a soft-bricked FritzBox 7530 after installing OpenWrt](./how-to-fix-soft-bricked-fritzbox-7530-after-openwrt-install.md)
    > 3. (this post)
