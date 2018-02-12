# CachedRemoteData

An extension of
[krisajenkins/remotedata](http://package.elm-lang.org/packages/krisajenkins/remotedata/latest)
that includes support for cached values.

The `krisajenkins/remotedata` package provides the bricks for a simple state
machine when dealing with remote data:

```
        NotAsked
           |
           v
    +-- Loading --+
    |             |
    v             V
Success a     Failure e
```

This package adds support for two additional states to refresh the data while
keeping its previous value:

```
         NotAsked
            |
            v
     +-- Loading --+
     |             |
     v             V
 Success a     Failure e
   |   ^           |
   v   |           |
Refreshing a <-----+
   |   ^
   v   |
 Stale e a
```

## Thanks

Thanks to [krisajenkins](https://github.com/krisajenkins) for the `remotedata`
package upon which this is built.

## License

Copyright © IMBY 2018

Distributed under the MIT license to be consistent with `krisajenkins/remotedata`.
