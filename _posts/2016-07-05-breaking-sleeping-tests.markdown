
```
# eating up all those CPUs
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &

# running test many times
many -c -n 20 -- nice -n 1 mvn verify -DskipUnitTests -Dcheckstyle.skip=true -Denforcer.skip=true -Dmaven.javadoc.skip=true | tee out

# cleaning up after yourself
kill %1 %2 %3 %4
```
