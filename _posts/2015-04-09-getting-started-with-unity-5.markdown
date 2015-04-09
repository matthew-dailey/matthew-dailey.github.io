---
layout: post
title:  "Getting started in Unity 5"
date:   2015-04-09 17:02:00
categories: unity
---

I had looked into making a game in [Unity](http://unity3d.com) before in version 4.6 when the 2D toolkit was released. Since then, Unity's UI components were released, and now Unity 5.0 came out. Not too many 5.0 features caught my eye, but I figured now would be a good opportunity to get started on an idea I had.

## Starting up Development

The Unity editor is only available on Windows and OSX, so I had to go with my Windows 8.1 machine (sorry Fedora!). I pretty much never develop in Windows, so I had to start from scratch with any tools beyond the Unity editor itself (which ships with MonoDevelop, an IDE for the open-source flavor of C#).

## Source Control

I've read from a few anecdotal sources that Mercurial works better with version tracking text-serialized binary data than Git. The first time I played with Unity, I used a Mercurial project for that reason, but never got to the point where I could come up with an opinion of it.

However, I ended up deciding on Git for this project for two simple reasons:

* I already know Git
* Unity's [Cloud Build](https://build.cloud.unity3d.com/login/) supports Git, but not Mercurial

Maybe Cloud Build will eventually support Mercurial, but I figured I'd go with what I know for this project.

## SourceTree and Bitbucket

So I had used Atlassian's SourceTree as my client to play with that Mercurial project in the past, so I figured I'd return to it for the new Git project (which it supports). I also decided to stick with Atlassian's [BitBucket](http://bitbucket.org) to host the remote repository of my code because it allows unlimited free personal (one-user) repositories.

## Unity and Git

[This blog post](http://www.strichnet.com/using-git-with-3d-games/) (which the author reposted as an answer to a [stackoverflow question](http://stackoverflow.com/questions/18225126/how-to-use-git-for-unity3d-source-control/18225479#18225479) gave me a good overview of how to set up Unity's assets to be better tracked. The article specifically lists two versions within 4.x that the instructions are for, but they ended up working on 5.0.0 as well.

Not sure if this is the proper method for setting up my .gitignore file via SourceTree, but I ended up doing this:

* `Right-Click` -> `Ignore` to one of the files I wanted to ignore.
* Open up `.gitignore` in Notepad, and paste in all of the records from that blog post.
* SourceTree automatically recognized the new ignores.

Then I was able to make a commit to my local repository, then push it up to BitBucket.
Windows Git weirdness

After pushing to BitBucket, I looked at the project in my browser, and it recommended adding a README, which I was able to do in the browser. After that, I wanted to pull the change back to my machine, but got a strange error message about my Git client having issues with Cygwin.

Google got me to [this stackoverflow answer](http://stackoverflow.com/questions/18502999/git-extensions-win32-error-487-couldnt-reserve-space-for-cygwins-heap-win32/24406417#24406417) that said to do some voodoo, and then everything will work. They were correct.
