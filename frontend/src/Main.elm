module Main exposing (..)

import Browser exposing (Document)
import Dict
import Html exposing (div)
import Html.Attributes exposing (class)
import Login
import Model exposing (..)
import Msg exposing (Msg(..))
import Selection
import Talks exposing (readSelections, saveSelections, updateSelection)
import User exposing (createUser)



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


init : () -> ( Model, Cmd msg )
init () =
    ( { user = Nothing
      , email = ""
      , selections = []
      , selectionsDb = Dict.fromList [] --TODO: save in API
      , rooms =
            [ --TODO: retrieve all time rooms
              { id = "1"
              , name = "101"
              , capacity = 20
              }
            , { id = "2"
              , name = "102"
              , capacity = 23
              }
            , { id = "3"
              , name = "103"
              , capacity = 25
              }
            , { id = "4"
              , name = "203"
              , capacity = 21
              }
            , { id = "5"
              , name = "103"
              , capacity = 25
              }
            , { id = "6"
              , name = "203"
              , capacity = 21
              }
            ]
      , timeBlocks =
            [ --TODO: retrieve all time blocks
              { id = "1"
              , from = "8:30"
              , to = "9:30"
              }
            , { id = "2"
              , from = "10:00"
              , to = "11:00"
              }
            , { id = "3"
              , from = "11:30"
              , to = "12:30"
              }
            , { id = "4"
              , from = "13:00"
              , to = "14:00"
              }
            ]
      , talks =
            [ --TODO: retrieve all talks
              { id = "1"
              , name = "Daniel Stach"
              , annotation = "Ve studiu s nejchytřejšímí lidmi světa aneb jak myslí velikání"
              , timeBlock = "1"
              , room = "2"
              }
            , { id = "2"
              , name = "Daniel Stach 2"
              , annotation = "Ve studiu s nejchytřejšímí lidmi světa aneb jak myslí velikání"
              , timeBlock = "2"
              , room = "3"
              }
            , { id = "3"
              , name = "Daniel Stach 3"
              , annotation = "Ve studiu s nejchytřejšímí lidmi světa aneb jak myslí velikání"
              , timeBlock = "3"
              , room = "4"
              }
            , { id = "4"
              , name = "Daniel Stach 4"
              , annotation = "Ve studiu s nejchytřejšímí lidmi světa aneb jak myslí velikání"
              , timeBlock = "4"
              , room = "1"
              }
            , { id = "5"
              , name = "Daniel Stach 5"
              , annotation = "Ve studiu s nejchytřejšímí lidmi světa aneb jak myslí velikání"
              , timeBlock = "1"
              , room = "4"
              }
            ]
      }
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTalk talk ->
            ( { model | selections = updateSelection talk model.talks model.selections }, Cmd.none )

        -- TODO: temp login
        Email email ->
            ( { model | email = email }, Cmd.none )

        SignIn email ->
            ( { model
                | user = Just <| createUser email
                , selections =
                    case model.user of
                        Nothing ->
                            []

                        Just user ->
                            readSelections user model.selectionsDb
              }
            , Cmd.none
            )

        SignOut ->
            ( { model
                | user = Nothing
                , selectionsDb =
                    case model.user of
                        Nothing ->
                            model.selectionsDb

                        Just user ->
                            saveSelections user model.selections model.selectionsDb
                , selections = []
              }
            , Cmd.none
            )



-- VIEW


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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
