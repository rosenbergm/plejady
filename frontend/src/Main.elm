module Main exposing (..)

import Browser exposing (Document)
import Model exposing (..)
import Msg exposing (Msg)
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
