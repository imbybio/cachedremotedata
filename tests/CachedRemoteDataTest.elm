module CachedRemoteDataTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import CachedRemoteData exposing(..)
import RemoteData
import Result


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
        , describe "fromResult"
            [ test "Ok v" <|
                \() ->
                    Expect.equal
                        (Success "ok")
                        (fromResult (Result.Ok "ok"))
            ,  test "Err e" <|
                \() ->
                    Expect.equal
                        (Failure "err")
                        (fromResult (Result.Err "err"))
            ]
        ]
