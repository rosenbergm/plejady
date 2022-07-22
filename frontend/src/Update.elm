module Update exposing (update)

import Dict
import Model exposing (Model, getBlockTalks, getTalk)
import Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTalk talk ->
            ( { model
                | selections =
                    --TODO: select the talk using API
                    if List.member talk model.selections then
                        List.filter (\selection -> selection /= talk) model.selections

                    else
                        talk
                            :: List.filter
                                (\selection ->
                                    not
                                        (List.member selection
                                            (case getTalk model talk of
                                                Nothing ->
                                                    []

                                                Just talkObj ->
                                                    List.map (\t -> t.id) (getBlockTalks model talkObj.timeBlock)
                                            )
                                        )
                                )
                                model.selections
              }
            , Cmd.none
            )

        -- TODO: temp login
        Email email ->
            ( { model
                | email = email
              }
            , Cmd.none
            )

        SignIn profile ->
            ( { model
                | user = Just profile
                , selections =
                    case Dict.get profile.email model.selectionsDb of
                        --TODO: fetch from API
                        Nothing ->
                            []

                        Just selections ->
                            selections
              }
            , Cmd.none
            )

        SignOut ->
            ( { model
                | user = Nothing
                , selectionsDb = Dict.insert model.email model.selections model.selectionsDb --TODO: save in API
                , selections = []
              }
            , Cmd.none
            )
