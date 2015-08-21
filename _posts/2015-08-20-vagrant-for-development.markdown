---
layout: post
title:  "*Actually* developing in Vagrant"
date:   2015-08-20 19:00:00
categories: vagrant intellij
---

If you've had my experience trying to start with [Vagrant](https://www.vagrantup.com/), you were intrigued by the pitch:

> "If you're a **developer**, Vagrant will isolate dependencies and their configuration within a single disposable, consistent environment, without sacrificing any of the tools you're used to working with (editors, browsers, debuggers, etc.)."

You then finish the tutorials, but feel like they skipped over the part where you *develop* in the VM.  The tutorials go over how to get Apache working with your already-developed application whose code you put in the shared `/vagrant` directory, but what if you wanted to do your development in the VM?

## The Use Cases

* C++ Development.  Most C++ dependencies are distributed via the package manager, so playing with any sufficiently complex C++ code base requires installing a good amount of software directly to your system.
* Repeatable dev environment.  Distribute one dev environment to your whole team.
* Throwaway dev environment.  Want to play around with `node` for a few days?  Make a VM, play around for a bit, then let it go

## First try: Java and IntelliJ

