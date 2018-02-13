module CachedRemoteDataTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import CachedRemoteData exposing(..)
import RemoteData exposing(RemoteData)


constructors : Test
constructors =
    describe "Constructors"
        [ describe "fromRemoteData"
            [ test "NotAsked" <|
                \() ->
                    Expect.equal
                        NotAsked
                        (fromRemoteData RemoteData.NotAsked)
            ]
        , describe "fromValue"
            [ test "Nothing" <|
                \() ->
                    Expect.equal
                        NotAsked
                        (fromValue Nothing)
            , test "Just v" <|
                \() ->
                    Expect.equal
                        (Success "ok")
                        (fromValue (Just "ok"))
            ]
        ]
