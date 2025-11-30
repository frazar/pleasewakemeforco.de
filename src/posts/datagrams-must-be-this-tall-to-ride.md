---
date: 2025-11-30 
title: Datagrams must be this tall to ride
---

# Datagrams must be this tall to ride

About that time my ISP started dropping IP datagrams of a certain size.

<!-- more -->

The end of the month is nearing, and my Internet Service Provider (ISP) contract
is bound to be silently renewed. 

Here in Germany, ADSL contracts are not cheap, but can save a non-negligible
amount of money if you sign up for a 2-year contracts. These contracts typically
have an initial period of time in which you get a discounted monthly fee. We're
talking about a _big_ discount, as big as 3x lower fees for the first 12 months.
After the initial period, the fee goes back to normal, but you can't cancel the contract
before the end of the 2nd year of contract. On average, you save some money, but
you must endure the annoyance of switching to a different ISP after the second
year.

So I set to find a new ISP and, thanks to [Check24
website](https://www.check24.de/), found the ISP with the best offer of the
month: Maingau Energie.

The company seems quite new to the ADSL market, but their reviews seem solid.
Also, Maingau Energie does not force you to buy or rent their router equipment,
and they explicitly mentioned my current ADSL modem, a 2nd hand [FRITZ!Box
7530](https://fritz.com/en/pages/service-fritz-box-7530), as compatible.

So I subscribed. Little did I know about what I was really signing up for.

After a couple of weeks, I get an appointment for a technician to setup the 
ADSL line. As they leave my house, I'm already firing up the FRITZ!Box admin
panel and setting up the ADSL parameters and PPPoE credentials. I'm expecting now to see what my new public IP looks like but instead I get...

![](./datagrams-must-be-this-tall-to-ride/1-pppoe-timeout.png){ loading=lazy }
/// caption
The FRITZ!Box logs show a PPPoE timeout.
///

Uhm. Strange.

Looking closer at the admin panel, I can confirm that the ADSL training has completed fine, and shows no error.

![](./datagrams-must-be-this-tall-to-ride/2-adsl-ok.png){ loading=lazy }
/// caption
The ADSL status page shows that the connection was estalbished successfully.
///

meaning that the ADSL parameters should be right.


*[ISP]: Internet Service Provider
