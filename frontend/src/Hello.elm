module Hello exposing (main)

import Browser exposing (Document)
import Html exposing (..)


main : Program String Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    {}


init : String -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )


type Msg
    = Name String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )


view : Model -> Document Msg
view _ =
    { title = "Plejády"
    , body =
        [ p [] [ text "Hello!" ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
