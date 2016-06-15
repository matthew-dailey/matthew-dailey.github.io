---
layout: post
title:  "Choosing a Wireless Channel"
date:   2016-02-21 20:00:00
tags: home-networking
---

I recently decided to relocate the router in my house upstairs where I'm setting up my new home office.  This seemed like the simplest way to get a wired connection, and also the least destructive (compared to, say, trying to wire up the house for ethernet).

So now the TV (really, the conduit for Netflix) is further from the router, so I'd expect the signal to be worse, but overall not affect performance.  First attempt: Netflix streamed fine.  Second attempt: nothing, followed by slow loading, and finally the dreaded *standard definition television*.

## Wireless Channels

First off, in your wireless router's settings, you can select a Channel for it to broadcast on.  These channels correspond to frequencies, and North American routers are supposed to use Channels 1 to 11, which exist within the 2.41 to 2.47 GHz range.

I won't claim to know too much about wireless signals, channel widths, or any of that.  My first hypothesis was "the fewer networks that use the same channel as me, the less conflict there will be."  By now, I think this is *mostly* correct, but there is some extra magic.

## Help me, Google

Googling around, [this article](http://www.howtogeek.com/howto/21132/change-your-wi-fi-router-channel-to-optimize-your-wireless-signal/) (July 2013, so probably still relevant) gives a little overview of the problem, and recommends a Windows utility for seeing what channels are in use from other networks.  Trying to find a similar utility for Fedora, I wound up on [askubuntu](http://askubuntu.com/questions/309458/is-there-a-program-to-see-channels-used-by-wifi-networks-similar-to-vistumbler) (ironic, but still relevant), and the one that ended up helping me was `wicd`, specifically `wicd-cli`.

You can see my comment there with my helpful one-liner,

`wicd-cli --wireless --list-networks | awk '{print $3}' | sort -n | uniq -c`

This gives counts for how many networks (that my laptop can see) that are running on each channel.  The output of that (in the back of my house with my TV) looks like:

```
1 Channel
5 1
4 6
3 11
3 149
```

Channels 1, 6, and 11 seem to be pretty heavily used.  Why no love for the channels inbetween?  If you look back at the "Fun Technical notes" section of the `howtogeek` article, it explains this.

>If you look closely, you’ll notice that each of the channels are 5 MHz away from each other, but the Channel Width for 2.4 GHz is actually 20 MHz. What this means is while that the channel might be set to channel 6, it’s also partially using 5 and 7, and probably slightly interfering with 4 and 8.

So they (and others) recommend using channels 1, 6, and 11 because their frequencies are more than the "channel width" away from eachother.  Another [2010 post](http://www.dslreports.com/forum/r24974694-Wireless-channel-selection) seems to corroborate this idea.

So, what's with channel 149?  That's part of the 5 GHz wifi band (that my router does not support).  Another [howtogeek article](http://www.howtogeek.com/222249/whats-the-difference-between-2.4-ghz-and-5-ghz-wi-fi-and-which-should-you-use/) (July 2015 this time) gives some more background, and this helpful tidbit:

>Keep in mind, 5Ghz is ideal for connecting in smaller, open spaces, and you’ll experience better data transmission rates but once you start to spread out and move away from the Internet access point, your results may begin to diminish.

So if that holds true, and even if my router supported it, it might still not be the best choice considering my house has, you know, *walls* between the main places we use the wifi.

## Putting it to use

Using `wicd`, I ran around the house and kept track of the channel usage in different rooms.   I realized that at the front of the house, there were no channel collisions with my channel, but at the back where the TV is situated, there were multiple collisions!  Using `wicd-gtk` I was able to see the networks sorted by strength, and other networks on the same channel had higher strength, which I assume is what got in the way.

## Which Channel to pick?

So in my initial hypothesis, I figured I should just pick an unoccupied channel, but we see the channel width problem can arise which still leads to partial interference.

So, without any science to back me up, I decided to go with channel 3 as an experiment (note: it has yet to be seen if I will actually gather any data to inform my further decisions on this).  I figured that I would rather go with more partial interference (from networks on channels 1 and 6) and no "full" interference (from the same channel).

I'll see how this goes; I just know I was having trouble on channel 11.

## Feedback
Let me know on Twitter if I've made mistakes in my approach to this problem, or in my solution.  I learn more by being wrong, and I'd also love to get great wireless signal in my house :)
