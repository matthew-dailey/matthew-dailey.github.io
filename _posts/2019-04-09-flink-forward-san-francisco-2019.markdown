---
layout: post
title:  "Flink Forward San Francisco 2019"
date:   2019-04-09 21:00:00
tags: flink kubernetes
---

Last week, I had a great time attending [Flink Forward SF 2019](https://sf-2019.flink-forward.org/).
Now, I really liked the conference since there were a lot of talks where I was able to take away actionable best practices from the other professionals using [Apache Flink](https://flink.apache.org/).

And of course I'd be remiss if I didn't mention I gave a talk myself
(just check out the [conference schedule!](https://sf-2019.flink-forward.org/conference-program))

But I wanted to use this page for some highlights of what I saw and what I learned while I was there.

##  Lyft's Flink Kubernetes Operator

Lyft engineers gave a talk about a [Kubernetes Operator](https://coreos.com/operators/)
used to launch Flink clusters as a single Kubernetes resource.
The Kubernetes Operator framework is something open-sourced by the CoreOS team that builds on the base Kubernetes
[Custom Resource Definition (CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).

Kubernetes CRDs allow users to define their own resources (like how _pods_ or _deployments_ are built-in resources),
which gives users the power to do something like make a resource that understands when to scale itself,
or when to start or stop itself.

Lyft's Kubernetes Operator lets users define a "Flink Cluster" as a resource,
which will spin up one or more high-availability Flink Job Manager pods, and one or more Flink Task Manager pods.
Here are some of the other key points:
* Lyft's team creates one of these resources for _every Flink job_.  This essentially makes the Kubernetes deployment work like a Hadoop YARN deployment.
* The resource can be set up with...
  * its own IAM role to give IAM isolation between jobs
  * Flink image tag to give flexibility to run different versions of Flink per job.
I do wonder know how you handle writing client code to submit jobs against all the different version of Flink.
Notably I'm thinking of how Flink 1.6 changed the client code to submit jobs.
  * a specific parallelism value. This can be based on the workload of the job, or the number of Task Managers created

Lyft plans to open-source this project at the end of April 2019.
