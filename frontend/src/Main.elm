module Main exposing (main)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


main : Program String Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

type alias Id = String

type alias Room =
    {
        id: Id,
        name: String,
        capacity: Int
    }

type alias TimeBlock =
    {
        id: Id,
        from: String,
        to: String
    }

type alias Talk =
    {
        id: Id,
        name: String,
        annotation: String,
        room: Id,
        timeBlock: Id
    }

type alias User =
    {
        email: String,
        selections: List String
    }

type alias Model =
    {
        user: Maybe User,
        rooms: List Room,
        timeBlocks: List TimeBlock,
        talks: List Talk
    }


init : String -> ( Model, Cmd Msg )
init _ =
    ({
        user = Nothing,
        rooms = [ --TODO: retrieve all time rooms
            {
                id = "1",
                name = "101",
                capacity = 20
            },
            {
                id = "2",
                name = "102",
                capacity = 23
            },
            {
                id = "3",
                name = "103",
                capacity = 25
            },
            {
                id = "4",
                name = "203",
                capacity = 21
            },
            {
                id = "5",
                name = "103",
                capacity = 25
            },
            {
                id = "6",
                name = "203",
                capacity = 21
            }
        ],
        timeBlocks = [ --TODO: retrieve all time blocks
            {
                id = "1",
                from = "8:30",
                to = "9:30"
            },
            {
                id = "2",
                from = "10:00",
                to = "11:00"
            },
            {
                id = "3",
                from = "11:30",
                to = "12:30"
            },
            {
                id = "4",
                from = "13:00",
                to = "14:00"
            }
        ],
        talks = [ --TODO: retrieve all talks
            {
                id = "1",
                name = "Daniel Stach",
                annotation = "Ve studiu s nejchytřejšímí lidmi světa aneb jak myslí velikání",
                timeBlock = "1",
                room = "2"
            },
            {
                id = "2",
                name = "Daniel Stach 2",
                annotation = "Ve studiu s nejchytřejšímí lidmi světa aneb jak myslí velikání",
                timeBlock = "2",
                room = "3"
            },
            {
                id = "3",
                name = "Daniel Stach 3",
                annotation = "Ve studiu s nejchytřejšímí lidmi světa aneb jak myslí velikání",
                timeBlock = "3",
                room = "4"
            },
            {
                id = "4",
                name = "Daniel Stach 4",
                annotation = "Ve studiu s nejchytřejšímí lidmi světa aneb jak myslí velikání",
                timeBlock = "4",
                room = "1"
            },
            {
                id = "5",
                name = "Daniel Stach 5",
                annotation = "Ve studiu s nejchytřejšímí lidmi světa aneb jak myslí velikání",
                timeBlock = "1",
                room = "4"
            }
        ]
    }, Cmd.none )


type Msg
    = Name String | Login | Logout | SelectTalk String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTalk talk -> ({
                model | user = case model.user of
                    Nothing -> Nothing
                    Just user -> --TODO: select the talk using API
                        if List.member talk user.selections then
                            Just { user | selections = (List.filter (\selection -> selection /= talk) user.selections)}
                        else
                            Just { user | selections = (talk :: (List.filter (\selection -> not (List.member selection (
                                case findTalk model.talks talk of
                                    Nothing -> []
                                    Just talkObj ->  List.map (\t -> t.id) (getBlockTalks model.talks talkObj.timeBlock)
                            ))) user.selections))}
            }, Cmd.none)
        Login -> --TODO: google auth
            ( { model | user = Just {
                email = "maxa.ondrej@student.alej.cz",
                selections = [] --TODO: fetch selected talks from API
            }}, Cmd.none )
        Logout ->
            ( { model | user = Nothing}, Cmd.none )
        _ ->
            ( model, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "Plejády"
    , body =
        case model.user of
            Nothing ->
                [ div [ class "page" ] [viewLoginBlock] ]
            Just user ->
                [ div [ class "page" ] [viewSelectBlock model user] ]
    }

viewLoginBlock: Html Msg
viewLoginBlock =
    div [ class "login"] [
        h1 [] [text "Plejády"],
        p [] [text "Pro přihlášení použijte svoje školní e-maily končící @student.alej.cz."],
        p [] [text "Přihlášky pod jiným e-mailem nejsou možné."],
        button [ onClick Login ] [text "Přihlásit pomocí školního účtu"]
    ]

viewSelectBlock: Model -> User -> Html Msg
viewSelectBlock model user =
    div [ class "selection"] [
        div [class "navigation"] [
            div [class "title"] [
                h1 [] [text "Plejády *"]
            ],
            div [class "auto-save"] [
                span [] [
                    text "Změny se automaticky ukládají!"
                ]
            ],
            div [class "logged-in"] [
                span [] [
                    text "Přihlášen/a jako ",
                    b [] [text user.email]
                ]
            ],
            div [class "logout"] [
                button [ onClick Logout ] [text "Odhlásit se"]
            ]
        ],
         div [class "logged-in-mobile"] [
             span [] [
                 text "Přihlášen/a jako ",
                 b [] [text user.email]
             ]
         ],
         viewTalks model user
    ]

viewTalks: Model -> User -> Html Msg
viewTalks model user =
    div [class "talks"] [
        table [] [
            thead [] [
                tr [] (
                    (th [] [
                            div [ class "talks-desc"] [
                                span [ class "blocks-desc" ] [ text "Blok →"],
                                span [ class "rooms-desc" ] [ text "Místnost →"]
                            ]
                        ]) :: (List.map (\room -> th [] [text room.name] ) model.rooms)
                )
            ],
            tbody [] (
                (List.map (\block -> tr []
                    ((th [] [
                        div [class "block-desc"] [
                            span [] [text block.from],
                            span [] [text "—"],
                            span [] [text block.to]
                        ]
                    ]) :: (List.map (\room -> case (getTalk model.talks room.id block.id) of
                        Just talk -> td [
                                class (if (List.member talk.id user.selections) then "active" else ""),
                                onClick (SelectTalk talk.id)
                            ] [
                                h3 [] [text talk.name],
                                p [] [text talk.annotation]
                            ]
                        Nothing -> td [] []
                    ) model.rooms))
                ) model.timeBlocks)
            )
        ]
    ]

getTalk: List Talk -> String -> String -> Maybe Talk
getTalk talks room block =
    case talks of
        [] -> Nothing
        (theHead :: theRest) ->
            if theHead.room == room && theHead.timeBlock == block then Just theHead else getTalk theRest room block

findTalk: List Talk -> String -> Maybe Talk
findTalk talks talk =
    case talks of
        [] -> Nothing
        (theHead :: theRest) ->
            if theHead.id == talk then Just theHead else findTalk theRest talk

getBlockTalks: List Talk -> String -> List Talk
getBlockTalks talks block =
    doGetBlockTalks [] talks block

doGetBlockTalks: List Talk -> List Talk -> String -> List Talk
doGetBlockTalks talks toRead block =
    case toRead of
        [] -> talks
        (theHead :: theRest) ->
            if theHead.timeBlock == block then doGetBlockTalks (theHead :: talks) theRest block else doGetBlockTalks talks theRest block

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
