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

states : Test
states =
    describe "State checking predicates"
        [ describe "isRefreshing"
            [ test "True" <|
                \() ->
                    Expect.equal
                        True
                        (isRefreshing (Refreshing "ok"))
            , test "False" <|
                \() ->
                    Expect.equal
                        False
                        (isRefreshing NotAsked)
            ]
        ]

mapping : Test
mapping =
    describe "Mapping functions"
        [ describe "map"
            [ test "NotAsked" <|
                \() ->
                    Expect.equal
                        NotAsked
                        (map String.length NotAsked)
            , test "Success v" <|
                \() ->
                    Expect.equal
                        (Success 2)
                        (map String.length (Success "ok"))
            , test "Failure e" <|
                \() ->
                    Expect.equal
                        (Failure "err")
                        (map String.length (Failure "err"))
            , test "Refreshing v" <|
                \() ->
                    Expect.equal
                        (Refreshing 2)
                        (map String.length (Refreshing "ok"))
            , test "Stale e v" <|
                \() ->
                    Expect.equal
                        (Stale "err" 2)
                        (map String.length (Stale "err" "ok"))
            ]
        , describe "mapError"
            [ test "NotAsked" <|
                \() ->
                    Expect.equal
                        NotAsked
                        (mapError String.length NotAsked)
            , test "Success v" <|
                \() ->
                    Expect.equal
                        (Success "ok")
                        (mapError String.length (Success "ok"))
            , test "Failure e" <|
                \() ->
                    Expect.equal
                        (Failure 3)
                        (mapError String.length (Failure "err"))
            , test "Refreshing v" <|
                \() ->
                    Expect.equal
                        (Refreshing "ok")
                        (mapError String.length (Refreshing "ok"))
            , test "Stale e v" <|
                \() ->
                    Expect.equal
                        (Stale 3 "ok")
                        (mapError String.length (Stale "err" "ok"))
            ]
        , describe "mapBoth"
            [ test "NotAsked" <|
                \() ->
                    Expect.equal
                        NotAsked
                        (mapBoth String.length String.length NotAsked)
            , test "Success v" <|
                \() ->
                    Expect.equal
                        (Success 2)
                        (mapBoth String.length String.length (Success "ok"))
            , test "Failure e" <|
                \() ->
                    Expect.equal
                        (Failure 3)
                        (mapBoth String.length String.length (Failure "err"))
            , test "Refreshing v" <|
                \() ->
                    Expect.equal
                        (Refreshing 2)
                        (mapBoth String.length String.length (Refreshing "ok"))
            , test "Stale e v" <|
                \() ->
                    Expect.equal
                        (Stale 3 2)
                        (mapBoth String.length String.length (Stale "err" "ok"))
            ]
        , describe "andMap"
            (
                [ (Stale "e1" "a", Stale "e2" "b", Stale "e1" ("a", "b"))
                , (Stale "e" "a", Refreshing "b", Stale "e" ("a", "b"))
                , (Stale "e" "a", Success "b", Stale "e" ("a", "b"))
                , (Refreshing "a", Stale "e" "b", Stale "e" ("a", "b"))
                , (Success "a", Stale "e" "b", Stale "e" ("a", "b"))
                , (Stale "e1" "a", Failure "e2", Failure "e1")
                , (Failure "e1", Stale "e2" "b", Failure "e1")
                , (Failure "e", Success "b", Failure "e")
                , (Success "a", Failure "e", Failure "e")
                , (Stale "e" "a", Loading, Failure "e")
                , (NotAsked, Stale "e" "b", Failure "e")
                , (Failure "e", NotAsked, Failure "e")
                , (Loading, Failure "e", Failure "e")
                , (Refreshing "a", Refreshing "b", Refreshing ("a", "b"))
                , (Refreshing "a", Success "b", Refreshing ("a", "b"))
                , (Success "a", Refreshing "b", Refreshing ("a", "b"))
                , (Loading, Success "b", Loading)
                , (NotAsked, Loading, Loading)
                , (NotAsked, Success "b", NotAsked)
                , (Success "a", Success "b", Success ("a", "b"))
                ]
                |> List.map (
                    \(a, b, r) ->
                        test ((toString a)++" | "++(toString b)) <|
                            \() ->
                                Expect.equal r (map (,) a |> andMap b)

                    )
                )
        , describe "map2"
            [ test "Success a, Success b" <|
                \() ->
                    Expect.equal
                        (Success ("a", "b"))
                        (map2 (,) (Success "a") (Success "b"))
            ]
        , describe "map3"
            [ test "Success a, Success b, Success c" <|
                \() ->
                    Expect.equal
                        (Success ("a", "b", "c"))
                        (map3 (,,) (Success "a") (Success "b") (Success "c"))
            ]
        ]

chaining: Test
chaining =
    describe "Chaining functions (andThen)"
        [ test "Loading" <|
            \() ->
                Expect.equal
                    NotAsked
                    (andThen (\v -> Success (String.length v)) Loading)
        , test "Success v" <|
            \() ->
                Expect.equal
                    (Success 2)
                    (andThen (\v -> Success (String.length v)) (Success "ok"))
        , test "Refreshing v" <|
            \() ->
                Expect.equal
                    NotAsked
                    (andThen (\v -> Success (String.length v)) (Refreshing "ok"))
        , test "Stale e v" <|
            \() ->
                Expect.equal
                    NotAsked
                    (andThen (\v -> Success (String.length v)) (Stale "err" "ok"))
        ]
