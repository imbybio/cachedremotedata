module CachedRemoteDataTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import CachedRemoteData exposing(..)
import RemoteData exposing(RemoteData)


all : Test
all =
    describe "Constructors"
        [ test "fromRemoteData" <|
            \() ->
                Expect.equal
                    NotAsked
                    (fromRemoteData RemoteData.NotAsked)
        ]
