---
layout: post
title:  "Getting tests to pass in Java 8"
date:   2017-04-01 12:00:00
tags: java
---

I recently went through the fun (no, really!) task of ensuring a large codebase was able to run on Java 8.
It had originally been written to work on Java 6 and Java 7, and Java 6 support was dropped before I started working with it.
The transition to Java 8 is intended to be seamless, but it's easy to have a codebase that accidentally relies on
undefined JVM behavior.

# HashSet and HashMap iteration order

## The problem

`HashMap` ([j7](http://docs.oracle.com/javase/7/docs/api/java/util/HashMap.html) [j8](http://docs.oracle.com/javase/8/docs/api/java/util/HashMap.html)) and
`HashSet` ([j7](http://docs.oracle.com/javase/7/docs/api/java/util/HashSet.html) [j8](http://docs.oracle.com/javase/8/docs/api/java/util/HashSet.html))
are commonly used classes in Java's Collections API.
`HashSet` explicitly states (in both Java 7 and 8 documentation) that it does not have a defined iteration order:

> It makes no guarantees as to the iteration order of the set; in particular, it does not guarantee that the order will remain constant over time.

`HashMap` also states iteration order is undefined:

> This class makes no guarantees as to the order of the map; in particular, it does not guarantee that the order will remain constant over time.

In Java 8, changes were made to `HashMap` and `HashSet` in [JEP-180](http://openjdk.java.net/jeps/180) to improve
performance during high-collision scenarios.  They explicitly state

> This change will likely result in a change to the iteration order of the HashMap class.
The HashMap specification explicitly makes no guarantee about iteration order.
The iteration order of the LinkedHashMap class will be maintained.

So, any code relying on that iteration order ends up breaking.
For the most part, this reliance manifests as generating String representations of data structures.
In other words, serialized JSON, or SQL.

## How to fix it

* Use a fluent object - jackson for JSON.  Note that org.json's `JSONObject` does not properly perform equality checks
  * mention jsonassert project, but note how it conflicts with org.json if it's already in your classpath
* Use [LinkedHashMap](http://docs.oracle.com/javase/7/docs/api/java/util/LinkedHashMap.html) or
[LinkedHashSet](http://docs.oracle.com/javase/7/docs/api/java/util/LinkedHashSet.html) to have a predictable sort order
between versions of Java.
* If a class requires a specific iteration order, then the data structure should be sorted.
This can be accomplished with either [TreeSet](http://docs.oracle.com/javase/7/docs/api/java/util/TreeSet.html),
an implementation of `SortedSet`, which extends `Set`;
or [TreeMap](http://docs.oracle.com/javase/7/docs/api/java/util/TreeMap.html),
an implementation of `SortedMap`, which extends ``Map`.

# Running tests with a different JDK

`-Dsurefire.jvm=/path/to/other/jvm/bin/java`
