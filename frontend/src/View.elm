module View exposing (view)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (class)
import Login
import Model exposing (Model)
import Msg exposing (Msg(..))
import Selection


view : Model -> Document Msg
view model =
    { title = "Plejády"
    , body =
        [ div [ class "page" ]
            [ case model.user of
                Nothing ->
                    Login.view model

                Just user ->
                    Selection.view model user
            ]
        ]
    }
