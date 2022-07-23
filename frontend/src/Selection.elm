module Selection exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Talks exposing (getTalkByRoomAndBlock)
import User exposing (User)


view : Model -> User -> Html Msg
view model user =
    div [ class "selection" ]
        [ div [ class "navigation" ]
            [ div [ class "title" ]
                [ h1 [] [ text "Plejády *" ]
                ]
            , div [ class "auto-save" ]
                [ span []
                    [ text "Změny se automaticky ukládají!"
                    ]
                ]
            , div [ class "logged-in" ]
                [ span []
                    [ text "Přihlášen/a jako "
                    , b [] [ text user.email ]
                    ]
                ]
            , div [ class "logout" ]
                [ button [ onClick SignOut ] [ text "Odhlásit se" ]
                ]
            ]
        , div [ class "logged-in-mobile" ]
            [ span []
                [ text "Přihlášen/a jako "
                , b [] [ text user.email ]
                ]
            ]
        , div [ class "talks" ]
            [ table []
                [ thead []
                    [ tr []
                        (th []
                            [ div [ class "talks-desc" ]
                                [ span [ class "blocks-desc" ] [ text "Blok →" ]
                                , span [ class "rooms-desc" ] [ text "Místnost →" ]
                                ]
                            ]
                            :: List.map (\room -> th [] [ text room.name ]) model.rooms
                        )
                    ]
                , tbody []
                    (List.map
                        (\block ->
                            tr []
                                (th []
                                    [ div [ class "block-desc" ]
                                        [ span [] [ text block.from ]
                                        , span [] [ text "—" ]
                                        , span [] [ text block.to ]
                                        ]
                                    ]
                                    :: List.map
                                        (\room ->
                                            case getTalkByRoomAndBlock room.id block.id model.talks of
                                                Just talk ->
                                                    td
                                                        [ class
                                                            (if List.member talk.id model.selections then
                                                                "active"

                                                             else
                                                                ""
                                                            )
                                                        , onClick (SelectTalk talk)
                                                        ]
                                                        [ h3 [] [ text talk.name ]
                                                        , p [] [ text talk.annotation ]
                                                        ]

                                                Nothing ->
                                                    td [] []
                                        )
                                        model.rooms
                                )
                        )
                        model.timeBlocks
                    )
                ]
            ]
        ]
