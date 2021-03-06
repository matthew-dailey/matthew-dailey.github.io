---
layout: post
title:  "Waking Sleeping Tests"
date:   2016-07-10 10:40:00
tags: java testing linux
---

## The Problem

When running through your test suite on your own machine, everything passes and the code looks like it's in a great place.  As soon as its run by CI, you see the flaky integration tests fail day after day.  What gives?  I tend to see two situations (sometimes of my own making) that result in these failures.

* `Thread.sleep()` calls in the test
* A too-short timeout for some part of the test

The reason these problems crop up on CI is that the CI machine's CPU tends to be fully utilized (or over-utilized).  In that case, the timeouts or `Thread.sleep()` calls tend to not last long enough.

Let's look at scenarios with `Thread.sleep()`.  These tests need to be refactored, but how does one go about doing that?  The first step is always reproducing the failure.

## Refactor Part 1 - Reproducing the Failure

I very recently figured out a simple way to reproduce these failures with the help of a few Linux commands (which also work on OS X).  To start, I would suggest running in a VM allocated with only 1 CPU.  [Vagrant](https://www.vagrantup.com/docs/getting-started/) is a good tool to help with that.

### tool - dd

First, we need a simple way to start eating up CPU cycles.  The [`dd`](http://man7.org/linux/man-pages/man1/dd.1.html) command can be used in a clever way to completely use one CPU.

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
$> nice -n 5 ./run-my-test.sh
...see the failure...
# stop the instance of dd
$> kill %1
```

Additionally, running multiple instances of `dd` can help here.  There is some trial-and-error with finding the correct value for `nice` and/or how many instances of `dd` to run.  Watching the test's process in `top` or `htop` to see how much CPU it gets is helpful.

Now that you can reproduce the error, you can determine when a fix has _most likely_ fixed the test.  I say "most likely" to really mean that you've reduced the occurance of the test failure to some acceptable value, possibly even less than 0.1%.

## Refactor Part 2 - Remove the flakiness

Refactoring flaky tests that rely on `Thread.sleep()` could be an entire _series_ of blog posts.  So, I'll give some high-level advice on this that might get fleshed out in subsequent posts.

* `Thread.sleep()` is used to wait for _something_ to occur.  Figure out a way to recognize when that happens.
* With asynchronous operations, the best case is that some form of `onSuccess()` or `onFailure()` callback can be attached.  This should remove the need for arbitrary waiting.  This can usually be expressed with Java [Futures](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/Future.html) or Guava [ListenableFutures](https://github.com/google/guava/wiki/ListenableFutureExplained).
* Have an asynchronous operation output into some form of synchronized data structure.  In the main test thread, do a blocking read from this data structure along with a timeout much longer than you'd expect the test to take.  The [BlockingQueue](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/BlockingQueue.html) interface is useful here, and the Guava helper [Queues.drain](https://google.github.io/guava/releases/14.0/api/docs/com/google/common/collect/Queues.html#drain(java.util.concurrent.BlockingQueue,%20java.util.Collection,%20int,%20long,%20java.util.concurrent.TimeUnit)) is great to do the blocking read.
* If nothing else, there should be some value to poll on to wait for the desired output.  Here you can still use `Thread.sleep()`, but many iterations of it with a smaller timeout.
  * There should also still be a maximum timeout to fail the test
  * The maximum timeout should be longer than the timeout when you started fixing the test (since otherwise the flaky test would still be failing), but the average-case test completion time will improve because of the shorter poll duration
