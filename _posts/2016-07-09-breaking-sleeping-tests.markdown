---
layout: post
title:  "Waking Sleeping tests"
date:   2016-07-09 11:00:00
tags: java testing linux
---

## The Problem

When running through your test suite on your own machine, everything passes and the code looks like it's in a great place.  As soon as its run by CI, you see the flaky integration tests fail day after day.  What gives?  I tend to see two situations (sometimes of my own making) that result in these failures.

* `Thread.sleep()` calls in the test
* A too-short timeout for some part of the test

The reason these problems crop up on CI is that the CI machine's CPU tends to be fully utilized (or over-utilized).  In that case, the `Thread.sleep()` calls tend to not last long enough, and same thing for the timeouts.

These tests need to be refactored, but how does one go about doing that?

## Refactor Pt. 1 - Reproducing the Failure

### tool - dd
I very recently figured out a simple way to reproduce these failures with the help of a few Linux commands.  To start, I would suggest running in a VM allocated with only 1 CPU.  [Vagrant](https://www.vagrantup.com/docs/getting-started/) is a good tool to help with that.

Now for a simple way to start eating up CPU cycles.  The [`dd`](http://man7.org/linux/man-pages/man1/dd.1.html) command can be used in a clever way to completely use one CPU.

```
dd if=/dev/zero of=/dev/null
```

This tells `dd` to read from `/dev/zero`, which just constantly produces zero-bytes, and write them to `/dev/null`.  This essentially does nothing, but can take up 100% of a CPU if nothing else is running.

### tool - nice

Now with `dd` running, you can run your flaky test with a high `nice` value.  [`nice`](http://man7.org/linux/man-pages/man1/nice.1.html) gives a process (and any of its child processes) a scheduling priority.  Zero is the highest priority of non-root processes, and is the default.

To run your process with a lower priority, use a higher number up to 19.

```
nice -n 1 script-to-run-just-my-test.sh
```

### Put it together

With these tools in hand, we can go ahead and run the test, provoking a failure.

```
$> dd if=/dev/zero of=/dev/null &
$> nice -n 5 run-my-test.sh
...see the failure...
# stop the instance of dd
$> kill %1
```

There is some trial-and-error with finding the correct value for `nice` as well as if you want to run multiple instances of `dd`.  Watching the processes in `top` or `htop` to see how much CPU they get is helpful


```
# eating up all those CPUs
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &

# nice=1 gives 75%
# nice=5 gives 50%
# nice=10 gives 25%
# nice=19 gives pretty much nothing

# running test many times
many -c -n 20 -- nice -n 1 mvn verify -DskipUnitTests -Dcheckstyle.skip=true -Denforcer.skip=true -Dmaven.javadoc.skip=true | tee out

# cleaning up after yourself
kill %1 %2 %3 %4
```
