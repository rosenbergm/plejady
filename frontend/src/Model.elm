module Model exposing (..)

import Dict exposing (Dict)


type alias Id =
    String


type alias Room =
    { id : Id
    , name : String
    , capacity : Int
    }


type alias TimeBlock =
    { id : Id
    , from : String
    , to : String
    }


type alias Talk =
    { id : Id
    , name : String
    , annotation : String
    , room : Id
    , timeBlock : Id
    }


type alias User =
    { email : String
    , token : String
    }


type alias Model =
    { user : Maybe User
    , email : String -- TODO: temp login
    , selections : List String
    , selectionsDb : Dict String (List String) --TODO: save in API
    , rooms : List Room
    , timeBlocks : List TimeBlock
    , talks : List Talk
    }


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


getTalk : Model -> String -> Maybe Talk
getTalk model talk =
    List.head
        (List.filter
            (\t -> t.id == talk)
            model.talks
        )


getTalkByRoomAndBlock : Model -> String -> String -> Maybe Talk
getTalkByRoomAndBlock model room block =
    List.head
        (List.filter
            (\t -> t.room == room && t.timeBlock == block)
            model.talks
        )


getBlockTalks : Model -> String -> List Talk
getBlockTalks model block =
    List.filter
        (\talk -> talk.timeBlock == block)
        model.talks
