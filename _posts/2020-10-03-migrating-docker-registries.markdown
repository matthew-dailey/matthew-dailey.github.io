---
layout: post
title:  "Migrating Docker Registries"
date:   2020-10-03 21:00:00
tags: docker managing delegating case-study
---

## What is the problem?

Starting in September 2020, my team (along with my peer teams) needed to migrate to a new remote Docker registry.
The team in charge of the registries were migrating to save costs (more than 10x savings!)
as well as increase throughput by running in the same region as our other software.
Great idea!

The registry team gave lots of great advice, thorough documentation on old and new URIs,
the new authentication mechanism, timeline, etc.

The timeline looked like this:
* Sep 1: New registry available
* Oct 1: Old registry becomes read-only
* Nov 1: Old registry is shut off

## What is the state of how builds work?

Now when you take a look at a problem like this on the surface, you might think this is what needs doing:
* Update each git repo to push to and pull from the new registry

But when you start to take a closer look at the problem, there is a _lot_ more to it.
In order to figure that out, you need to know more about the ecosystem.
* The overall team needs to update around 10 git repos that consume or produce docker images
* There are dependencies between git repos: some repos produce images used by other repos
* Some git repos have circular dependencies (whoops!):
one git repo had a dependency on an older tag of a docker image that was produced by the same git repo

We can validate that the migration is a success when both
* Our cloud software can be built and deployed using the new registry
* Our on-premise software can be built and packaged using the new registry

## What do we need to do?

So with that, you start to realize there is a decent amount of work.
* Because there is a graph of dependencies between git repos,
some repositories must be updated first to push to the new docker registry before other repos can pull from the new registry
* This graph is also not a [DAG](https://en.wikipedia.org/wiki/Directed_acyclic_graph) because we knew of some circular dependencies.
This isn't as bad as it could be, luckily, since the graph involves using old docker image tags,
so it should not result in a chicken-and-egg problem.
* But wait, to solve that, how _do_ we migrate old docker image tags?
If you update a git repo to push to the new docker registry, only the most recent image tag will be pushed.
You need a way to migrate old tags without migrating absolutely every docker image.
* Since there is a linear dependency graph,
how do we parallelize the effort in order to accomplish this within the deadline?
We could update some git repos to push to the new registry,
but continue to read from the old registry until all of its dependent repos are pushing to the new registry.
* That also means we cannot switch to pushing exclusively to the new registry.
We need to push to both old and new docker registries for a while or else
the build for downstream repos will break when it needs a new image that is only being pushed to the new docker registry.
* That also means that we need to _stop_ pushing to the old docker registry before the old registry goes read-only.
If we don't stop doing that, it means any build that attempts to push to the old registry will start to
fail as it will no longer be allowed to push starting October 1

## How does a team actually accomplish this?

It was my job, as a manager on the team, to help the team work through how to do this.
We decided to **optimize** for:
* parallelizing the work
* individual teams unblocking themselves as quickly as possible

So to kick off this work, we
* Assigned ownership of each git repo to one team
* Teams identified if their repo had a dependency on pushing images, pulling images, or both
* Teams identified which other repos (and thus which teams) blocked their migration
* Teams would migrate repositories to first push to both old and new registries
* Once any dependent repos were migrated to push, a repo could migrate to pull from the new registry
* Find one owner (on my team) to centrally migrate any old images
* Once both exit criteria are met (cloud and on-premise software can be built using the new registries),
then we can stop pushing to the old registries

## What would you do differently next time?

* Have a kickoff meeting with everyone involved.  It was apparent not every team had the same context on the problem,
the constraints, or the work required to accomplish the goals.
