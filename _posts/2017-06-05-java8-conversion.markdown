---
layout: post
title:  "Getting tests to pass in Java 8"
date:   2017-06-05 12:00:00
tags: java
---

I recently went through the fun (no, really!) task of ensuring a large codebase was able to run on Java 8.
It had originally been written to work on Java 6 and Java 7, and Java 6 support was dropped before I started working with it.
The transition to running on Java 8 is intended to be seamless, but it's easy to have a codebase that accidentally relies on
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
For the most part, this reliance manifests when generating String representations of data structures.
In other words, serializing JSON, or building SQL.

## How to fix it

Depending on what objects are being compared, there are a few options for making fixes.

### JSON

For JSON, the main solution is to do `equals` comparison of marshalled JSON objects rather than the String representation.

```java
  public static void assertStringsEqual(String message, String expected, String actual) throws IOException {
    ObjectMapper objectMapper = new ObjectMapper();

    JsonNode expectedNode = objectMapper.readTree(expected);
    JsonNode actualNode = objectMapper.readTree(actual);

    Assert.assertEquals(message, expectedNode, actualNode);
  }
```

This uses `com.fasterxml.jackson.databind.JsonNode` and `com.fasterxml.jackson.databind.ObjectMapper` from the
`com.fasterxml.jackson.core:jackson-databind` Maven dependency.

**Note** that `org.json`'s `JSONObject` does not properly perform equality checks of JSON trees,
so I don't recommend using it for this purpose.

Another library I looked at was [JSONassert](https://github.com/skyscreamer/JSONassert), but it includes a duplicate
class that is in `org.json` (`JSONString`).  My project is configured to disallow duplicate classes,
so this dependency would have been a hassle to bring in.

### Other data

These other sort-order-dependent bugs mostly came up when comparing expected SQL statements with constructed SQL.
The actual SQL was sorted differently in Java 7 and Java 8, so I had to make it consistent using these techniques.

* Replace `HashMap` with [LinkedHashMap](http://docs.oracle.com/javase/7/docs/api/java/util/LinkedHashMap.html),
and `HashSet` with [LinkedHashSet](http://docs.oracle.com/javase/7/docs/api/java/util/LinkedHashSet.html)
to have a consistent sort order in both versions of Java.
* If a class requires a specific iteration order, then the data structure should be sorted.
This can be accomplished with either [TreeSet](http://docs.oracle.com/javase/7/docs/api/java/util/TreeSet.html),
an implementation of `SortedSet`, which extends `Set`;
or [TreeMap](http://docs.oracle.com/javase/7/docs/api/java/util/TreeMap.html),
an implementation of `SortedMap`, which extends `Map`.

## How to test the fix

`-Dsurefire.jvm=/path/to/other/jvm/bin/java`
