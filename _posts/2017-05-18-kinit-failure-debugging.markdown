---
layout: post
title:  "Debugging kinit failure with strace"
date:   2017-05-18 16:00:00
tags:   kerberos strace
---

**tl;dr**, turn off `iptables` on the KDC node. _Of course_ it was `iptables`.

## The full story

I had previously set up Kerberos and Hadoop manually and now had the task of at least semi-automating the process.
I had successfully built automation around installing the KDC and creating the `admin/admin` principal,
and was able to `kinit` as `admin/admin` _on the KDC node_.

When automating the creation of per-node principals, I consistently ran into this error:

```
kinit: Cannot contact any KDC for realm 'EXAMPLE.COM' while getting initial credentials
```

For reference, here's the full output for successful and unsuccessful `kinit`s.

```
# success on KDC node (hn0)
[matt@matt7-hn0 ~]$ kinit admin/admin
Password for admin/admin@EXAMPLE.COM:

[matt@matt7-hn0 ~]$ klist
Ticket cache: FILE:/tmp/krb5cc_531
Default principal: admin/admin@EXAMPLE.COM

Valid starting     Expires            Service principal
05/17/17 18:39:29  05/18/17 18:39:29  krbtgt/EXAMPLE.COM@EXAMPLE.COM
    renew until 05/24/17 18:39:29
```

```
# failure on client node (dn0)
[matt@matt7-dn0 ~]$ kinit -V admin/admin
Using default cache: /tmp/krb5cc_531
Using principal: admin/admin@EXAMPLE.COM
kinit: Cannot contact any KDC for realm 'EXAMPLE.COM' while getting initial credentials
```

## Debugging

#### SSH failure?

Can the client not resolve the hostname of the KDC server?
I was able to SSH from the client to the KDC server using the IP address, fully-qualified hostname, and short hostname.
So, no problem resolving the address.

#### krb5.conf mismatch?

I already knew `kinit` worked on the KDC node, so maybe there was a mistmatch in `/etc/krb5.conf`.
I was able to verify the `krb5.conf` was identical on the two machines (just `sha256sum` each file),
so it wasn't that.

#### Some other network issue?

Using `kinit` with the verbose flag (`-V`) was not giving me any additional useful information,
so I needed to add in some other tools.  Since this is a CentOS 6.8 machine, let's try **strace**!

```
# On client node, this returns immediately and fails.
# On KDC node, this waits for the password to be typed in (which I did), then succeeds.
strace kinit -V admin/admin &> out
```

I did not use any flags with `strace` because
(a) I was not sure what I was searching for, and
(b) honestly, I forgot the useful flags for `strace` since I last used it :)

If you want to know the awesome flags for `strace`,
Julia Evans has a [great zine](https://jvns.ca/blog/2015/04/14/strace-zine/) about it.

#### Using strace on kinit

What I was searching for were instances of the `connect` syscall reaching out to the IP of the KDC node.

```
# successful on KDC node (hn0)
connect(3, {sa_family=AF_INET, sin_port=htons(88), sin_addr=inet_addr("10.10.178.123")}, 16) = 0
sendto(3, "j\201\3110\201\306\241\3\2\1\5\242\3\2\1\n\243\0160\f0\n\241\4\2\2\0\225\242\2\4\0"..., 204, 0, NULL, 0) = 204
gettimeofday({1495043558, 931567}, NULL) = 0
gettimeofday({1495043558, 931608}, NULL) = 0
poll([{fd=3, events=POLLIN}], 1, 1000)  = 1 ([{fd=3, revents=POLLIN}])
recvfrom(3, "k\202\2\3410\202\2\335\240\3\2\1\5\241\3\2\1\v\242\0260\0240\22\241\3\2\1\23\242\v\4"..., 4096, 0, NULL, NULL) = 741
close(3)                                = 0
```

```
# failure on client node (dn0) - see the EHOSTUNREACH
connect(3, {sa_family=AF_INET, sin_port=htons(88), sin_addr=inet_addr("10.10.178.123")}, 16) = 0
sendto(3, "j\201\3110\201\306\241\3\2\1\5\242\3\2\1\n\243\0160\f0\n\241\4\2\2\0\225\242\2\4\0"..., 204, 0, NULL, 0) = 204
gettimeofday({1495043522, 503784}, NULL) = 0
gettimeofday({1495043522, 503838}, NULL) = 0
poll([{fd=3, events=POLLIN}], 1, 1000)  = 1 ([{fd=3, revents=POLLERR}])
recvfrom(3, 0x7f54c19b3340, 4096, 0, 0, 0) = -1 EHOSTUNREACH (No route to host)
close(3)
```

Great!  At this point I had clear evidence that the host was unreachable from the client.  Thanks `strace`!

I was just lucky that my next guess was right: was `iptables` enabled on the KDC node?  It was.
Disabling `iptables` (`sudo service iptables stop`) allowed me to connect from the client node, success!

## Checklist

This is the quick version of the debug steps I took to figure out the issue.

* Can you SSH from the client to KDC node?
* Are the `/etc/krb5.conf` files identical?
* Is `iptables` on and set up with a port whitelist that does not include port 88?
