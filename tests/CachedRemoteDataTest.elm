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
            , test "Loading" <|
                \() ->
                    Expect.equal
                        Loading
                        (fromRemoteData RemoteData.Loading)
            , test "Success v" <|
                \() ->
                    Expect.equal
                        (Success "ok")
                        (fromRemoteData (RemoteData.Success "ok"))
            , test "Failure e" <|
                \() ->
                    Expect.equal
                        (Failure "err")
                        (fromRemoteData (RemoteData.Failure "err"))
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

getters : Test
getters =
    describe "Functions that return partial data"
        [ describe "value"
            [ test "NotAsked" <|
                \() ->
                    Expect.equal
                        Nothing
                        (value NotAsked)
            , test "Success v" <|
                \() ->
                    Expect.equal
                        (Just "ok")
                        (value (Success "ok"))
            , test "Failure e" <|
                \() ->
                    Expect.equal
                        Nothing
                        (value (Failure "err"))
            , test "Refreshing v" <|
                \() ->
                    Expect.equal
                        (Just "ok")
                        (value (Refreshing "ok"))
            , test "Stale e v" <|
                \() ->
                    Expect.equal
                        (Just "ok")
                        (value (Stale "err" "ok"))
            ]
        , describe "result"
            [ test "Loading" <|
                \() ->
                    Expect.equal
                        Nothing
                        (result Loading)
            , test "Success v" <|
                \() ->
                    Expect.equal
                        (Just (Result.Ok "ok"))
                        (result (Success "ok"))
            , test "Failure e" <|
                \() ->
                    Expect.equal
                        (Just (Result.Err "err"))
                        (result (Failure "err"))
            , test "Refreshing v" <|
                \() ->
                    Expect.equal
                        Nothing
                        (result (Refreshing "ok"))
            , test "Stale e v" <|
                \() ->
                    Expect.equal
                        (Just (Result.Err "err"))
                        (result (Stale "err" "ok"))
            ]
        , describe "remoteData"
            [ test "Loading" <|
                \() ->
                    Expect.equal
                        RemoteData.Loading
                        (remoteData Loading)
            , test "Refreshing v" <|
                \() ->
                    Expect.equal
                        RemoteData.Loading
                        (remoteData (Refreshing "ok"))
            , test "Stale e v" <|
                \() ->
                    Expect.equal
                        (RemoteData.Failure "err")
                        (remoteData (Stale "err" "ok"))
            ]
        ]
