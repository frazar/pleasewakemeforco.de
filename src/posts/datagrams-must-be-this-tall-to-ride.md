---
date: 2025-11-30 
title: Datagrams must be this tall to ride
---

# Datagrams must be this tall to ride

About that time my ISP started dropping IP datagrams of a certain size.

<!-- more -->

## Entrée

The end of the month is nearing, and my Internet Service Provider (ISP) contract
is bound to be silently renewed. 

Here in Germany, ADSL contracts are not cheap. Luckily, you can save a
non-negligible amount of money if you sign up for a 2-year contract. This kind
of contract typically has an initial period of time in which you get a
discounted monthly fee. We're talking about a _big_ discount, as big as 3x lower
fees for the first 12 months. After the initial period, the fee goes back to
normal, but you can't cancel the contract before the end of the 2nd year of
contract. On average, you save some money, but you must endure the annoyance of
switching to a different ISP after the second year.

So I set to find a new ISP and, thanks to [Check24
website](https://www.check24.de/), found the ISP with the best offer of the
month: Maingau Energie.

![](./datagrams-must-be-this-tall-to-ride/0-maingau.png){ loading=lazy }
/// caption
The homepage of Maingau Energie
///

The company is small compared to the German telecom titans, but their reviews
seem solid. Also, Maingau Energie does not force you to buy or rent their ADSL
modem, and they explicitly mentioned my current ADSL modem, a 2nd hand
[FRITZ!Box 7530](https://fritz.com/en/pages/service-fritz-box-7530), as
compatible.

So I subscribed. Little did I know about what I was really signing up for.

After a couple of weeks, I get an appointment for a technician to setup the ADSL
line. As they leave my house, I'm already firing up the FRITZ!Box admin panel
and setting up the ADSL parameters and PPPoE credentials. I'm expecting now to
see what my new public IP looks like but instead I get...

![](./datagrams-must-be-this-tall-to-ride/1-pppoe-timeout.png){ loading=lazy }
/// caption
The FRITZ!Box logs show a PPPoE timeout.
///

Uhm. Strange.

Looking closer at the admin panel, I can confirm that the ADSL training has
completed fine, and no error is reported.

![](./datagrams-must-be-this-tall-to-ride/2-adsl-ok.png){ loading=lazy }
/// caption
The ADSL status page shows that the connection was estalbished successfully.
///

suggesting that the physical link and the ADSL parameters are working. I double
check all the configurations, the credentials, and the physical connections, but
nothing changes. I leave it alone for some time, hoping it's just some network
configuration that has not yet propagated. After a few days, I hard reset the
ADSL modem and repeat the whole process once more. But alas, PPPoE still shows
no sign of being alive.

I then decide to reach to technical support, explaining my issues, attaching
screenshots of the current configuration, the ADSL status, and the the error I
face. Soon, I get a new technician appointment. I learn from the technician that
they know nothing about PPPoE, and that the only thing they can do is to check
the quality of the ADSL connection with a handheld device. This is not at all
different from the one the first technician used when they setup the line. So,
I'm surprised very little when my ADSL line turns out to be working line.

![](./datagrams-must-be-this-tall-to-ride/3-adsl-tester.png){ loading=lazy }
/// caption
An ADSL testing device shows that the ADSL works fine.
///

I take a photo of the test result and forward it to the Maingau technical
support. Surely, now that the ADSL functionality has been confirmed, they will
be looking at the PPPoE issue on their syst..

![](./datagrams-must-be-this-tall-to-ride/4-ticket-closed.png){ loading=lazy }
/// caption
An email from Maingau technical support communicates that the issue is resolved.
///

or, as GMail automatic translation puts it

> Dear Ladies and Gentlemen,
> 
> Your fault with the number "MAING-XXXXXXXXXXXXXX" has been set to the 
> status "Resolved" and is therefore closed.

I try multiple times to contact customer support to convince them that no, the
issue is not resolved, and that yes, I've tried rebooting the ADSL router.

Exasperated, I decide it's time I try to do something on my own.


## Warming up

You see, the nice thing about my FRITZ!Box 7530 router is that 
[it has OpenWRT support](https://openwrt.org/toh/avm/avm_fritz_box_7530). Malignant
minds might think that I have been waiting for this excuse to rip the default 
firmware out and replace it with a free firmware.

The process was pretty uneventful, thanks to the detailed OpenWRT Wiki. Soon I was
able to access the router via `ssh` and starting combining the instructions provided 
by my ISP with the many 
[DSL configuration examples of the wiki](https://openwrt.org/docs/guide-user/network/wan/isp-configurations).

Finally, I found a promising combination network configuration:

```
config atm-bridge 'atm'
    option vpi '1' # Specified by the ISP
    option vci '32' # Specified by the ISP
    option encaps 'llc'
    option payload 'bridged'
    option nameprefix 'dsl'

config dsl 'dsl'
    option annex 'j'
    option tone 'b'
    option ds_snr_offset '0'

config device
    option name 'dsl0'

config device
    option type '8021q'
    option ifname 'dsl0'
    option vid '7' # VLAN ID 7, as specified by ISP
    option name 'dsl0.7'

config interface 'wan'
    option device 'dsl0.7'
    option proto 'pppoe'
    option username '$ISP_PROVIDED_USERNAME'
    option password '$ISP_PROVIDED_PASSWORD'
```

and that... worked! No PPPoE timeout, an IP was negotiated and I could finally
connect to the internet! 

So all is good now, right? right??


## A bitter taste


*[ISP]: Internet Service Provider
