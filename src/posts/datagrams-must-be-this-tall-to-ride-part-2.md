---
date: 2026-10-29
title: Datagrams must be this tall to ride (Part 2)
---

_The finale of the post series about tall datagrams._

# TODO: write image

??? info "Other posts in the series"

    > 1. [Datagrams must be this tall to ride (Part 1)](./datagrams-must-be-this-tall-to-ride-part-1.md)
    2.
    > 2. [How to fix a soft-bricked FritzBox 7530 after installing OpenWrt](./how-to-fix-soft-bricked-fritzbox-7530-after-openwrt-install.md)
    > 3. (this post)

## Problem statement

In the previous posts in this series, I blabbered about how changing my ISP
provider got me in the situation where outgoing TCP datagrams from my router
where sometimes dropped depending on their size.

<div class="inline-svg">
--8<-- "posts/datagrams-must-be-this-tall-to-ride-part-2/10-problem-statement.svg"
</div>

I do not know _why_ these specific sizes where cursed, but at least I know
_which_ ones are cursed. So maybe I can do something about it?

## The plan

The idea is to

<div class="inline-svg">
--8<-- "posts/datagrams-must-be-this-tall-to-ride-part-2/20-solution-packet-inflater-only.svg"
</div>

Needs a shrinker too

<div class="inline-svg">
--8<-- "posts/datagrams-must-be-this-tall-to-ride-part-2/30-solution-full-chain.svg"
</div>

## The implementation

## Epilogue

??? info "Other posts in the series"

    > 1. [Datagrams must be this tall to ride (Part 1)](./datagrams-must-be-this-tall-to-ride-part-1.md)
    2.
    > 2. [How to fix a soft-bricked FritzBox 7530 after installing OpenWrt](./how-to-fix-soft-bricked-fritzbox-7530-after-openwrt-install.md)
    > 3. (this post)
