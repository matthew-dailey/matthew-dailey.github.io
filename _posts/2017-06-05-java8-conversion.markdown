---
layout: post
title:  "Getting tests to pass in Java 8"
date:   2017-06-05 12:00:00
tags: java
---

_Update: This article also appears on the [Rocana blog](http://blog.rocana.com/getting-tests-to-pass-in-java-8) with much nicer formatting_

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

So, any code relying on that iteration order ends up breaking between Java versions.
For the most part, this reliance manifests when generating String representations of data structures.
In other words, serializing JSON, or building SQL.

## How to fix it

### JSON

For JSON, the main solution is to perform `equals` comparison of marshalled JSON objects rather than the String representation.

```java
  public static void assertStringsEqual(String message, String expected, String actual) throws IOException {
    ObjectMapper objectMapper = new ObjectMapper();

    // marshall the JSON strings into JsonNode objects for comparison
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

### Other data types

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

## Building and Running tests with different Java versions

This is a pretty interesting one: my organization needed to continue _building_ with JDK 7,
but the tests also needed to pass when run with JDK 8.

If your project uses Maven, the Surefire plugin has the
`jvm` [configuration property](http://maven.apache.org/surefire/maven-surefire-plugin/test-mojo.html#jvm)
for specifying a different JVM when running tests.
Note that this property should point to the `java` executable, not the home directory for that JDK.

```
# on OSX
java8_path=/Library/Java/JavaVirtualMachines/jdk1.8.0_74.jdk/Contents/Home/bin/java
mvn clean test -Djvm=${java8_path}
```

Similarly, the Failsafe plugin also has the
`jvm` [configuration property](http://maven.apache.org/surefire/maven-failsafe-plugin/integration-test-mojo.html#jvm)
for specifying a different JVM when running integration tests, like with `mvn verify`.

And that's it!  If you were to build with JDK 8 as well, it's likely other issues would arise.
Whenever I get around to making Java 8 the minimum version, I'll probably write about the new issues we run into there.
