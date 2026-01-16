---
date: 2025-11-30
title: Datagrams must be this tall to ride
---

<!-- CHECKS:
- present time
- first person
-->

# Datagrams must be this tall to ride

About that time my ISP was dropping IP datagrams of a certain size.

<!-- more -->

## Entrée

It's July 2025. The end of the month is nearing, and my 2-year-long Internet
Service Provider (ISP) contract is bound to expire.

Here in Germany, ADSL contracts are not cheap. Luckily, you can save a
non-negligible amount of money if you sign up for a 2-year contract. This kind
of contract typically has an initial period of time in which you get a
discounted monthly fee. I'm talking about a _big_ discount. As big as 3x lower
fees for the first 12 months. After the initial period, the fee goes back to
normal, but you can't cancel the contract before the end of the 2nd year. On
average, you save some money, but you must endure the annoyance of switching to
a different ISP after the second year.

So I set to find a new ISP and, thanks to [Check24
website](https://www.check24.de/), found the ISP with the best offer of the
month: Maingau Energie.

![](./datagrams-must-be-this-tall-to-ride/0-maingau.png){ loading=lazy }
/// caption
A happy family of Maingau Energie customers. Not how nobody in the promotional
picture seems to be accessing the internet.
///

The company is small compared to the German telecom titans, but their reviews
seem solid. Also, Maingau Energie does not force you to buy or rent their ADSL
modem. Cherry on top: they explicitly mentioned my current ADSL modem, a second
hand [FRITZ!Box 7530](https://fritz.com/en/pages/service-fritz-box-7530), as
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

Looking closer at the admin panel, I can confirm that the ADSL "training" has
completed fine, and no error is reported.

![](./datagrams-must-be-this-tall-to-ride/2-adsl-ok.png){ loading=lazy }
/// caption
The ADSL status page shows that the connection was established successfully.
///

I double-check and redo all the configurations, the credentials, the physical
connections... nothing changes. Finally, I device to leave the router alone for
some time. I tell myself: "Perhaps it's just some network configuration that has
not yet propagated fully".

After a few days, I try to hard-reset the ADSL modem and repeat the whole
process once more. But alas, PPPoE still shows no signs of life.

I then decide to reach to technical support via email. I detail my issues,
attaching screenshots of the current configuration, the ADSL status, and the the
error I face. A new technician appointment is scheduled.

But when the technician arrives, they know nothing about the PPPoE
configuration. The only thing they can do is to check the quality of the ADSL
connection with a handheld device. This is not at all different from the one the
first technician used when they setup the line. So, I'm very little surprised
when my ADSL line turns out to be working fine.

![](./datagrams-must-be-this-tall-to-ride/3-adsl-tester.png){ loading=lazy }
/// caption
An Argus 163 ADSL testing device shows that the ADSL works fine. Notice how the
German word for "stop" is spelled with two "p"s.
///

I forward a photo of the test results to the Maingau technical support. Surely,
now that the ADSL functionality has been confirmed, they will be looking at the
PPPoE issue on their syst..

![](./datagrams-must-be-this-tall-to-ride/4-ticket-closed.png){ loading=lazy }
/// caption
An email from Maingau technical support declares the issue resolved.
///

or, as GMail automatic translation puts it

> Dear Ladies and Gentlemen,
>
> Your fault with the number "MAING-XXXXXXXXXXXXXX" has been set to the status
> "Resolved" and is therefore closed.

I try multiple times to contact customer support via phone or email to convince
them that no, the issue is not resolved, and that yes, I've tried rebooting the
ADSL router. Nobody takes my problem at heart.

Exasperated, I decide it's time I try to do something on my own.

## Warming up

You see, the nice thing about my FRITZ!Box 7530 router is that it has 🎉OpenWRT
support🎉.

> Malignant minds might think that I have been dying for an excuse to rip
> out the stock firmware and install OpenWRT. They are not wrong.

I head to [the OpenWRT wiki page dedicated to my
router](https://openwrt.org/toh/avm/avm_fritz_box_7530), I follow the flashing
procedure, and soon the router becomes truly mine. I then start combining the
VDSL parameters provided by my ISP with the many examples
[in the wiki](https://openwrt.org/docs/guide-user/network/wan/isp-configurations).
After a little bit of trial and error, I conjure the following configuration:

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
    option username '$ISP_PROVIDED_USERNAME' # Specified by the ISP
    option password '$ISP_PROVIDED_PASSWORD' # Specified by the ISP
```

and that... worked! No PPPoE timeout! An IP address is negotiated and I can
finally connect to the internet! Hell, I even got an IPv6 address.

So all is good now, right? Right??

## A bitter taste

I start surfing, but something is off. Sometimes, website fail to load.
Software updates don't go through. In most cases, the issues are intermittent,
almost forgivable. But in other cases the issues reproducing consistently.

Here are a few examples:

- On a Debian box, `docker login ghcr.io` _always_ fails with `TLS handshake
timeout`

```
$ echo test | docker login ghcr.io -u USERNAME --password-stdin
Error response from daemon: Get "https://ghcr.io/v2/": net/http: TLS handshake timeout
```

- On all Windows laptops, `winget update` was failing with the error message

```
PS C:\> winget update --all
Errore durante la ricerca nell'origine: 'msstore'
Si è verificato un errore imprevisto durante l'esecuzione del comando:
WinHttpSendRequest: 12002: Timeout dell'operazione

0x80072ee2 : unknown error
```

> _**Side Question:**_
> _Honestly, how do you force PowerShell to show error messages in English? On
> Linux, I would just set the `LC_ALL=C` environment variable. On Windows, is
> the only option to change the system language and reboot the machine?_

- The `steamcommunity.org` website wouldn't load,

  ![](./datagrams-must-be-this-tall-to-ride/41-steamcommunity-does-not-load.png){ loading=lazy }
  /// caption
  An email from Maingau technical support declares the issue resolved.
  ///

I decide to analyze the `steamcommunity.org` failure in more detail, since:

- the issue can be reproduced from a browser, which has very many useful tools
  to inspect network requests,
- I really wanted to replay Patrician III.

I open Firefox, start the developers tools, switch to the Network tab, and
ensure the "disable cache" checkbox is selected. I reload the page and, indeed,
I find that there is a specific asset that fails to be transferred, resulting
the website styling not loading.

TODO: Add picture

One of the key features of the Network tab is that, for every network request,
it can produce an equivalent curl command. I do exactly that by right-clicking
on the request and hit the "Copy" > "Copy as cURL (Windows)".

![](./datagrams-must-be-this-tall-to-ride/42-copy-as-curl.png){ loading=lazy }
/// caption
To whoever came up with this feature: I owe you a beer.
///

This gives me a big and noisy `curl` command, ready to be pasted into a `cmd`
prompt.

```cmd
C:\>curl.exe ^"https://community.akamai.steamstatic.com/public/javascript/applications/community/manifest.js?v=nbKNVX6KpsXN^&l=english^&_cdn=akamai^" ^
   -H ^"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0^" ^
   -H ^"Accept: */*^" ^
   -H ^"Accept-Language: en-US,en;q=0.9^" ^
   -H ^"Accept-Encoding: gzip, deflate, br, zstd^" ^
   -H ^"Sec-Fetch-Storage-Access: none^" ^
   -H ^"Connection: keep-alive^" ^
   -H ^"Referer: https://steamcommunity.com/^" ^
   -H ^"Sec-Fetch-Dest: script^" ^
   -H ^"Sec-Fetch-Mode: no-cors^" ^
   -H ^"Sec-Fetch-Site: cross-site^" ^
   -H ^"Priority: u=2^" ^
   -H ^"Pragma: no-cache^" ^
   -H ^"Cache-Control: no-cache^" ^
   -O NUL
curl: (52) Empty reply from server
```

All right, the error can be reproduce. Let's now try to minimize the command.
Surely, not all of these headers are _really_ needed. So I remove the
`-H ^"Cache-Control: no-cache^"` command line argument, and get

```patch
C:\>curl.exe ^"https://community.akamai.steamstatic.com/public/javascript/applications/community/manifest.js?v=nbKNVX6KpsXN^&l=english^&_cdn=akamai^" ^
     -H ^"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0^" ^
     -H ^"Accept: */*^" ^
     -H ^"Accept-Language: en-US,en;q=0.9^" ^
     -H ^"Accept-Encoding: gzip, deflate, br, zstd^" ^
     -H ^"Sec-Fetch-Storage-Access: none^" ^
     -H ^"Connection: keep-alive^" ^
     -H ^"Referer: https://steamcommunity.com/^" ^
     -H ^"Sec-Fetch-Dest: script^" ^
     -H ^"Sec-Fetch-Mode: no-cors^" ^
     -H ^"Sec-Fetch-Site: cross-site^" ^
     -H ^"Priority: u=2^" ^
     -H ^"Pragma: no-cache^" ^
     -o NUL

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  9061  100  9061    0     0  91644      0 --:--:-- --:--:-- --:--:-- 94385
```

The request... works!

Wait, what?

Ok now, time to think.

- Rationalization attempt 1: Perhaps the second request got answered by a
  different remote host? For good measure, I hardcode the IP of the host in the
  Windows HOSTS file. The results are still the same reproduce.

- Rationalization attempt 2: Maybe the issue is exactly the header I decided to
  remove? But no, deleting one of the other headers also makes the request
  succeed.

Ok I'm clueless by now. What if instead of removing an HTTP headers, I add one?
Well, this might make more troubles: the website's load balancer might strip my
request of any unexpected HTTP header, or even block the request outright.
Well let's try using a header name with `X-` prefix to increase our chances.
Also, let's use Bash from now on.

```bash
#!/bin/bash
set -uo pipefail

echo "Testing X-[numbers]: pattern with ALL original headers"
echo

function run_curl() {
    timeout 3 curl -s -o /dev/null \
        -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:142.0) Gecko/20100101 Firefox/142.0' \
        -H 'Accept: */*' \
        -H 'Accept-Language: en-US,en;q=0.5' \
        -H 'Accept-Encoding: gzip, deflate, br, zstd' \
        -H 'Connection: keep-alive' \
        -H 'Referer: https://steamcommunity.com/' \
        -H 'Sec-Fetch-Dest: script' \
        -H 'Sec-Fetch-Mode: no-cors' \
        -H 'Sec-Fetch-Site: cross-site' \
        "$@" \
        'https://community.akamai.steamstatic.com/public/javascript/applications/community/manifest.js?v=PU33sk4crNva&l=english&_cdn=akamai'
}

# Test range from 3 to 20 characters
for length in {3..20}; do
    header_name="X-$(printf '%0*d' $((length-2)) 1 | tr '0' '1')"

    printf "Length %2d (%s): " "$length" "$header_name"

    run_curl -H "$header_name: a"

    result=$?
    if [ $result -eq 0 ]; then
        echo " success"
    elif [ $result -eq 124 ]; then
        echo " TIMEOUT"
    else
        echo " FAILED"
    fi
done
```

```txt
Testing X-[numbers]: pattern with ALL original headers

Length 3 (X-1): TIMEOUT
Length 4 (X-11): TIMEOUT
Length 5 (X-111): success
Length 6 (X-1111): success
Length 7 (X-11111): TIMEOUT
Length 8 (X-111111): success
Length 9 (X-1111111): TIMEOUT
Length 10 (X-11111111): TIMEOUT
Length 11 (X-111111111): success
Length 12 (X-1111111111): success
Length 13 (X-11111111111): success
Length 14 (X-111111111111): success
Length 15 (X-1111111111111): success
Length 16 (X-11111111111111): success
Length 17 (X-111111111111111): success
Length 18 (X-1111111111111111): success
Length 19 (X-11111111111111111): success
Length 20 (X-111111111111111111): success
```

Oh-oh. This shows that the success or failure depends on the length of the
header being sent.

```
Testing different patterns with full headers:
  X-ABCDEFGH:  TIMEOUT
  Y-12345678:  TIMEOUT
  Custom1234:  TIMEOUT
  Headerasdf:  TIMEOUT
  X-TEST1234:  TIMEOUT
  MyHeader34:  TIMEOUT
```

It seems that the precise content of the header does not matter. It's the
_length_ of the header that matters.

To determine which are the request lengths that trigger the issue, I extend the
script to repeat the request over and over for a wider range of values. From the
outcome of the script, I generate a plot showing for each request size, how many
timeouts I get over 5 retries.
obtaining the following image.

![](./datagrams-must-be-this-tall-to-ride/X-compare-captures.jpg){ loading=lazy }
/// caption
TODO
///

This might explain why the issue occurs often, but not always. But why is the
request failing in the first place?

## Dissecting packets

Ok, it's time too look more closely at these network requests. In order to
capture the traffic on the DSL device, I fire up
[WireShark](https://www.wireshark.org/) on my laptop and install `tcpdump` on
the router with

```sh
opkg install tcpdump
```

Then I configure WireShark to connect via SSH to the router. Note that the
filtering rules here follow the `tcpdump` notation, which is slightly different
from the language to specify WireShark's filters.

I take a specific request and run it twice, once while connected to my ADSL and
once while connected to my mobile hotspot, and compare the two captures.

TODO: capture + breakdown

So I end up with a bunch of re-transmissions. But why? Is it because the ACK for
my request never gets there, or is it because the network response never comes
back?

TODO: Add graphical diagram

I can not capture packets as the server side. Unless..

## The ultimate test

Ok so the idea is to deploy a small Virtual Machine on the cloud, connect to it
via my ISP, and capture the traffic on both sides and see what exactly goes
missing.

TODO: Setup

![](./datagrams-must-be-this-tall-to-ride/X-compare-captures.jpg){ loading=lazy }
/// caption
TODO
///

TODO: Breakdown

For curiosity, I try the same test using ping. Ping sends ICMP packets rather
than TCP ones, but they too have a payload and its length can be configured with
the `-s` flag. Interestingly, the same failure pattern occurs.

TODO:

> Did they ever fit together?

https://youtu.be/-JIuKjaY3r4?t=203

So the common denominator between the two tests, is not anything at the Network
Layer, the Layer 3 of the ISO model. It's further down to Layer 2, where IP
reigns supreme.

# Unfolding the symptoms

The issue is that packets sent from my ADSL router to the internet never get
delivered if their size is within a specific size.

TODO: Add diagram of issue

# Drafting possible solutions

How to work around the issue?

My first attempt was to filter outbound packets on the router so that they are
split if they have a size matching one of the "forbidden" ones.

Pros:

- only requires processing on the sending side
- tested successfully without ping

Cons:

- sometime TCP packets are not allowed to be split

## Solution Attempt 2: Artificially increase datagram size

# Packet inflater

# Packet shrinker

## Conclusions

- Maingau Energie sucks

Follow-up work:

- Use eBPF instead
- extend to IPv6

\*[ISP]: Internet Service Provider \*[VDSL]: Very high speed Digital Subscriber Line

```

```
