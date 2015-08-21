---
layout: post
title:  "*Actually* developing in Vagrant"
date:   2015-08-20 19:00:00
categories: vagrant intellij
---

If you've had my experience trying to start with [Vagrant](https://www.vagrantup.com/), you were intrigued by the pitch:

> "If you're a **developer**, Vagrant will isolate dependencies and their configuration within a single disposable, consistent environment, without sacrificing any of the tools you're used to working with (editors, browsers, debuggers, etc.)."

You then finish the tutorials, but feel like they skipped over the part where you *develop* in the VM.  The tutorials go over how to get Apache working with your already-developed application whose code you put in the shared `/vagrant` directory, but what if you wanted to do your development within the VM?

## The Use Cases

* C++ Development.  Most C++ dependencies are distributed via the package manager, so playing with any sufficiently complex C++ code base requires installing a good amount of software directly to your system.
* Repeatable dev environment.  Distribute one dev environment to your whole team.
* Throwaway dev environment.  Want to play around with `node` for a few days?  Make a VM, play around for a bit, then let it go

## First try: Java and IntelliJ
Here is the code for [my first try](https://github.com/matthew-dailey/vagrantfiles/tree/0.0.0/intellij-java) at using Vagrant to actually develop with Java inside the Vagrant VM using an IDE (IntelliJ IDEA).

### Vagrantfile
The Vagrantfile is mostly straightforward.  Starting with the `vagrant init chef/centos-7.0`, I added X11 forwarding through SSH, extra memory, 4 CPUs, and specified a [provisioning script](#bootstrap.sh).  The extra CPUs are **needed**, or else you're in for a very sluggish experience with IntelliJ.
```
Vagrant.configure(2) do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "chef/centos-7.0"

  # ssh properties
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  config.vm.provider "virtualbox" do |vb|
    # These numbers gave great performance on laptop with
    # 16 GB memory
    # quad core i7-4710HQ
    vb.memory = "4096"
    vb.cpus = "4"
  end
  
  # script for provisioning dependencies
  config.vm.provision :shell, path: "bootstrap.sh"
end
```

### bootstrap.sh
You can name this script whatever you'd like as long as its specified in the Vagrantfile.  I designed mine to install libraries with `yum`, and any other software is installed manually (combinations of `wget` and `tar`).

The first tricky piece was discovering what X11 libraries needed installing from the bare-bones CentOS 7 image in order to launch IntelliJ.  Other IDEs (I've tried VSCode) required even more X11 and GTK libraries, especially if you wanted a monospaced font.
```
sudo yum update

devtools='
vim
git
'
x11_stuff='
xorg-x11-xauth
libXtst
libXrender
'
sudo yum install -y \
    $x11_stuff \
    $devtools
```

The only other "trick" in this script is that it will move any downloaded files to the `/vagrant` directory so that if you happen to build this image again, the downloaded files will exist on your host machine to speed up the provisioning.

### Running
The README describes how to take the VM for a spin.  You'll have to go through first-time setup of IntelliJ after making the VM, but otherwise this should be a fully-working solution for developing inside your VM with acceptable performance.

```
# mostly takes time to download and install dev tools
vagrant up

# ssh with X11 forwarding
vagrant ssh -- -Y

# you are now in the VM
git clone <my favorite java project>
idea.sh &> idea.log &
```
