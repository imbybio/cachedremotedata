module CachedRemoteData exposing
    ( CachedRemoteData(..)
    , CachedWebData
    , fromRemoteData
    , fromValue
    , fromResult
    , fromValueAndResult
    , fromValueAndRemoteData
    , remoteData
    , value
    , result
    , map
    , mapError
    , sendRequest
    , sendRequestWithValue
    , sendRequestWithCached
    )

{-|

An extension to the `RemoteData` package that supports cached values.

#Data types
@docs CachedRemoteData, CachedWebData

#Constructors
@docs fromRemoteData, fromValue, fromResult, fromValueAndResult, fromValueAndRemoteData

#Data access
@docs remoteData, value, result

#Mapping
@docs map, mapError

#Sending HTTP requests
@docs sendRequest, sendRequestWithValue, sendRequestWithCached
-}

import Http
import Result exposing (Result(..))
import RemoteData exposing (RemoteData)

{-|

A datatype representing fetched data with optional cached value.
-}

type CachedRemoteData e a
    = NotAsked
    | Loading
    | Failure e
    | Success a
    | Refreshing a
    | Stale e a


{-|
While `CachedRemoteData` can model any type of error, the most common one
you'll actually encounter is when you fetch data from a REST interface, and get
back `CachedRemoteData Http.Error a`. Because that case is so common,
`CachedWebData` is provided as a useful alias.
-}
type alias CachedWebData a =
    CachedRemoteData Http.Error a


{-|
Create a `CachedRemoteData` given a `RemoteData`.
-}
fromRemoteData : RemoteData e a -> CachedRemoteData e a
fromRemoteData data =
    case data of
        RemoteData.NotAsked ->
            NotAsked

        RemoteData.Loading ->
            Loading

        RemoteData.Failure e ->
            Failure e

        RemoteData.Success v ->
            Success v


{-|
Create a `CachedRemoteData` given a `Maybe` value.
-}
fromValue : Maybe a -> CachedRemoteData e a
fromValue data =
    case data of
        Nothing ->
            NotAsked

        Just v ->
            Success v


{-|
Create a `CachedRemoteData` given a `Result`.
-}
fromResult : Result e a -> CachedRemoteData e a
fromResult result =
    case result of
        Err e ->
            Failure e

        Ok x ->
            Success x


{-|
Create a `CachedRemoteData` given a `Maybe` value and `Result`.
-}
fromValueAndResult : Maybe a -> Result e a -> CachedRemoteData e a
fromValueAndResult maybe result =
    case ( maybe, result ) of
        ( Just v, Err e ) ->
            Stale e v

        _ ->
            fromResult result


{-|
Create a `CachedRemoteData` given a `Maybe` value and `RemoteData`.
-}
fromValueAndRemoteData : Maybe a -> RemoteData e a -> CachedRemoteData e a
fromValueAndRemoteData ma rd =
    case ( ma, rd ) of
        ( Just v, RemoteData.NotAsked ) ->
            Success v

        ( Just v, RemoteData.Loading ) ->
            Refreshing v

        ( Just v, RemoteData.Failure e ) ->
            Stale e v

        _ ->
            fromRemoteData rd


{-|
Turn a `CachedRemoteData` into a `RemoteData`.
-}
remoteData : CachedRemoteData e a -> RemoteData e a
remoteData cached =
    case cached of
        NotAsked ->
            RemoteData.NotAsked

        Loading ->
            RemoteData.Loading

        Failure e ->
            RemoteData.Failure e

        Success v ->
            RemoteData.Success v

        Refreshing _ ->
            RemoteData.Loading

        Stale e _ ->
            RemoteData.Failure e


{-|
Turn a `CachedRemoteData` into a `Maybe` value.
-}
value : CachedRemoteData e a -> Maybe a
value cached =
    case cached of
        Success v ->
            Just v

        Refreshing v ->
            Just v

        Stale _ v ->
            Just v

        _ ->
            Nothing


{-|
Turn a `CachedRemoteData` into a `Result`.
-}
result : CachedRemoteData e a -> Maybe (Result e a)
result cached =
    case cached of
        Success v ->
            Just (Result.Ok v)

        Failure e ->
            Just (Result.Err e)

        Stale e _ ->
            Just (Result.Err e)

        _ ->
            Nothing


{-|
Map a `CachedRemoteData` from type `a` to type `b`
-}
map : (a -> b) -> CachedRemoteData e a -> CachedRemoteData e b
map fn cached =
    case cached of
        Success v ->
            Success (fn v)

        Refreshing v ->
            Refreshing (fn v)

        Stale e v ->
            Stale e (fn v)

        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Failure e ->
            Failure e


{-|
Map a `CachedRemoteData` error from type `e` to type `f`
-}
mapError : (e -> f) -> CachedRemoteData e a -> CachedRemoteData f a
mapError fn cached =
    case cached of
        Failure e ->
            Failure (fn e)

        Stale e v ->
            Stale (fn e) v

        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Success v ->
            Success v

        Refreshing v ->
            Refreshing v


{-|
Convenience function for dispatching `Http.Request`s.
It's like `Http.send`, but yields a `CachedWebData` response.
-}
sendRequest : Http.Request a -> Cmd (CachedWebData a)
sendRequest =
    Http.send fromResult


{-|
Dispatch a `Http.Request`s with an initial value.
-}
sendRequestWithValue : Maybe a -> Http.Request a -> Cmd (CachedWebData a)
sendRequestWithValue value request =
    Http.send (fromValueAndResult value) request

{-|
Dispatch a `Http.Request`s with an initial `CachedWebData` value. This can
typically be used when refreshing a previously retrieved `CachedWebData`
response.
-}
sendRequestWithCached : CachedWebData a -> Http.Request a -> Cmd (CachedWebData a)
sendRequestWithCached cached request =
    sendRequestWithValue (value cached) request
