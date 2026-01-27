---
date: 2025-11-30
title: Datagrams must be this tall to ride
---

<!-- CHECKS:
- present time
- first person
-->

# Datagrams must be this tall to ride

Or what to do when your ISP drops IP datagrams of certain sizes.

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

![](./datagrams-must-be-this-tall-to-ride/00-maingau.png){ loading=lazy }
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

![](./datagrams-must-be-this-tall-to-ride/10-pppoe-timeout.png){ loading=lazy }
/// caption
The FRITZ!Box logs show a PPPoE timeout.
///

Uhm. Strange.

Looking closer at the admin panel, I can confirm that the ADSL "training" has
completed fine, and no error is reported.

![](./datagrams-must-be-this-tall-to-ride/20-adsl-ok.png){ loading=lazy }
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

![](./datagrams-must-be-this-tall-to-ride/30-adsl-tester.png){ loading=lazy }
/// caption
An Argus 163 ADSL testing device shows that the ADSL works fine. Notice how the
German word for "stop" is spelled with two "p"s.
///

I forward a photo of the test results to the Maingau technical support. Surely,
now that the ADSL functionality has been confirmed, they will be looking at the
PPPoE issue on their syst..

![](./datagrams-must-be-this-tall-to-ride/40-ticket-closed.png){ loading=lazy }
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

By default, the router gives little information for any investigation. But the
nice thing about my FRITZ!Box 7530 router is that it has ✨OpenWRT support✨.

> Malignant minds might think that I have been dying for an excuse to rip
> out the stock firmware and install OpenWRT. They are not wrong.

I head to [the OpenWRT wiki page dedicated to my
router](https://openwrt.org/toh/avm/avm_fritz_box_7530), I follow the flashing
procedure, and soon the router becomes _truly_ mine. I then start combining the
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

So all is good now, right?

Right??

## A bitter taste

I start surfing, but something is off. Sometimes, website fail to load. In most
cases, the issues are intermittent, almost forgivable. But in other cases the
issues reproduce consistently.

Here are a few examples:

- On a Debian box, `docker login ghcr.io` _always_ fails with `TLS handshake
timeout`

```
$ echo test | docker login ghcr.io -u USERNAME --password-stdin
Error response from daemon: Get "https://ghcr.io/v2/": net/http: TLS handshake timeout
```

- On all Windows devices, `winget update` was failing with the error message

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

- The `steamcommunity.org` website doesn't load,

  ![](./datagrams-must-be-this-tall-to-ride/41-steamcommunity-does-not-load.png){ loading=lazy }
  /// caption
  An email from Maingau technical support declares the issue resolved.
  ///

I decide to analyze the `steamcommunity.org` failure in more detail, since:

1. The issue can be reproduced from a browser, which has very many useful tools
   to inspect network requests,
2. I really wanted to replay Patrician III.

I open Firefox, start the developers tools, switch to the "Network" tab, and
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

This gives me a big and noisy `curl` command that I pasted into a `cmd`
prompt and run

```
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

All right, the error can be reproduced. Let's now try to minimize the command.
Surely, not all of these headers are _really_ needed. So I remove the last
`-H ...` command line argument, and get...

```
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

a successful response.

Wait, what? I've just removed a random header!

Ok now, time to think.

- Rationalization attempt 1: Perhaps the second request got answered by a
  different remote host? For good measure, I hardcode the IP of the host in the
  Windows HOSTS file. But even after that, the results are the same. Also,
  replaying the request any number of times does not change the outcomes.

- Rationalization attempt 2: Maybe the issue is exactly the header I decided to
  remove? But no, even without any of the other headers, the request
  succeeds.

Ok, I'll admit I'm a bit clueless by now. So let's try to explore more to make
sense of the situation.

What if instead of removing an HTTP header, I add one? Well, this might create
more troubles: the website's load balancer might strip my request of any HTTP
header it does not expect, or even block the request outright. I try using a
header name with the conventional `X-` name prefix to increase the chances of my
request not being dropped. Also, let's use Bash in WSL from now on.

```bash
#!/bin/bash

# run_curl: Sends the same HTTP request that fails in the browser,
#           but any extra HTTP header specified as arguments.
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

# Repeats the HTTP request with an extra, dummy header of increasing lenght. The
# header has the form:
#
#   X-1...1: a
#
# with the number of '1' characters varying from 3 to 20
for length in {3..20}; do
    # Build the header name and value
    header_name="X-$(printf '%0*d' $((length-2)) 1 | tr '0' '1')"

    printf "Header \"%s\" (Length %2d): " "$header_name" "$length"

    run_curl -H "$header_name: a"

    result=$?  # Get the exit code of the last command
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
Header "X-1" (Length 3): TIMEOUT
Header "X-11" (Length 4): TIMEOUT
Header "X-111" (Length 5): success
Header "X-1111" (Length 6): success
Header "X-11111" (Length 7): TIMEOUT
Header "X-111111" (Length 8): success
Header "X-1111111" (Length 9): TIMEOUT
Header "X-11111111" (Length 10): TIMEOUT
Header "X-111111111" (Length 11): success
Header "X-1111111111" (Length 12): success
Header "X-11111111111" (Length 13): success
Header "X-111111111111" (Length 14): success
Header "X-1111111111111" (Length 15): success
Header "X-11111111111111" (Length 16): success
Header "X-111111111111111" (Length 17): success
Header "X-1111111111111111" (Length 18): success
Header "X-11111111111111111" (Length 19): success
Header "X-111111111111111111" (Length 20): success
```

The results show that when the header has a length of 3, 4, 7, 9, or 10
characters the request fails with a timeout. In all other cases, the request
succeeds.

To make sure the header content is not significant, I run another test with a
bunch of random values, but same length:

```
X-ABCDEFGH:  TIMEOUT
Y-12345678:  TIMEOUT
Custom1234:  TIMEOUT
Headerasdf:  TIMEOUT
X-TEST1234:  TIMEOUT
MyHeader34:  TIMEOUT
```

In all cases, the timeout still occurs.

Conclusion: the content of the header does not matter. It's the _length_ of the
header that does.

To determine which are the request lengths that trigger the issue, I extend the
script to repeat the request over and over for a wider range of values. Also, to
reduce the chance of flukes, I repeat each test 5 times. I then plot a graph
showing the percentage of failures for a given requested size.

![](./datagrams-must-be-this-tall-to-ride/X0-failure-rate-vs-request-size.jpg){ loading=lazy }
/// caption
TODO
///

Is that.. a pattern?

## Dissecting packets

So far I have managed to define the conditions in which the request timeout is
observed. However it is not yet clear _why_ the timeouts occur. It's time too
look more closely at these network requests.

In order to capture the DSL device, I need to install `tcpdump` on the router.
Thanks to OpenWRT, this is as simple as running

```sh
opkg install tcpdump
```

I then fire up [WireShark](https://www.wireshark.org/) on my laptop and
configure it to connect via SSH to the router.

I take a specific request and run it twice, once while connected to my ADSL and
once while connected to my mobile hotspot, and compare the two captures.

TODO: capture + breakdown

Here we're seeing the (many) TCP requests exchanged between my router and the
remote host to get the steammcommunity.org

Comparing the two captures, I observe that
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

![](./datagrams-must-be-this-tall-to-ride/X0-compare-captures.jpg){ loading=lazy }
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

This test is interesting because it shows that both the TCP and ICMP requests
(which differ wildly) are affected in the same way. This suggests that the root
cause is not at Layer 3 of the ISO model.

It's further down to Layer 2, where IP reigns supreme.

# Drafting possible solutions

To summarize the above findings, my issue is that datagrams sent from my ADSL
router to the Internet are outright dropped if their size matches one of the
"cursed" sizes.

TODO: Add diagram of issue

How to address the issue?

My idea is to apply some packet manipulation to outbound packets to change their size and save the from the inevitable drop.

My first idea is to reduce the size of the packets with a "forbbiden" size by
forcing IP fragmentation of. This is quite simple to implement, because it uses
the fragmentation feature that is built in TCP. Additionally, fragmentation is a
built-in IP feature so, if the source host decides to fragment the IP packets
it sends, the destination host will automatically recombine the fragments.
I was even able to make the `ping` requests work! However, sometimes TCP packets
are not allowed to be fragmented. In particular, those related to the TLS
handshakes.

If reducing the packet size is not possible, then what about increasing it?
Unfortunately, the IPv4 payload can not be increased without also affecting how
the inner Layer 3 packets are parsed. However, the IPv4 header does not have a
fixed size. Indeed, the IPv4 standard allows the IP header to have a variable
number of "options", whose size can range from 0 to 40 bytes with steps of 4
bytes.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/IPv4_Packet-en.svg/2560px-IPv4_Packet-en.svg.png){ loading=lazy }
/// caption
By Michel Bakni - Postel, J. (September 1981) _RFC 791, IP Protocol, DARPA Internet Program Protocol Specification_, p. 1 DOI: [10.17487/RFC0791](dx.doi.org/10.17487/RFC0791), CC BY-SA 4.0, https://commons.wikimedia.org/w/index.php?curid=79949694
///

So a possiblity is to add a sufficient number of IP header options so that the
overall IP datagram size does not match any of the cursed sizes.
Unfortunately, IP header options are rarely used in the general Internet and intermediate routers might flag as malicious and drop IPv4 packets that specify these options. In practice

# Packet inflater

# Packet shrinker

## Conclusions

- Maingau Energie sucks

Follow-up work:

- Use eBPF instead
- extend to IPv6

## Acknoledgements

Thanks to the folks in the OpenWRT forum for listening to my crazy ravings.

\*[ISP]: Internet Service Provider \*[VDSL]: Very high speed Digital Subscriber Line
