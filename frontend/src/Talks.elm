module Talks exposing (..)

import Dict exposing (Dict)
import List.Extra
import User exposing (User)



-- TYPES


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



-- HELPERS


getTalk : String -> List Talk -> Result String Talk
getTalk talk talks =
    case List.Extra.find (\t -> t.id == talk) talks of
        Nothing ->
            Err "Talk not found"

        Just talkObj ->
            Ok talkObj


getTalkByRoomAndBlock : String -> String -> List Talk -> Maybe Talk
getTalkByRoomAndBlock room block talks =
    List.Extra.find (\t -> t.room == room && t.timeBlock == block) talks


getBlockTalks : String -> List Talk -> List Talk
getBlockTalks block talks =
    List.filter (\talk -> talk.timeBlock == block) talks


isSelected : String -> List String -> Bool
isSelected talk selections =
    List.member talk selections


deselectBlock : String -> List Talk -> List String -> List String
deselectBlock block talks selections =
    List.Extra.filterNot
        (\selection -> getBlockTalks block talks |> List.map (\t -> t.id) |> List.member selection)
        selections


selectTalk : Talk -> List String -> List String
selectTalk talk selections =
    talk.id :: selections


updateSelection : Talk -> List Talk -> List String -> List String
updateSelection talk talks oldSelections =
    let
        selections =
            deselectBlock talk.timeBlock talks oldSelections
    in
    if isSelected talk.id oldSelections then
        selectTalk talk selections

    else
        selections



--TODO: connect to API


saveSelections : User -> List String -> Dict String (List String) -> Dict String (List String)
saveSelections user selections db =
    Dict.insert user.email selections db


readSelections : User -> Dict String (List String) -> List String
readSelections user db =
    case Dict.get user.email db of
        Nothing ->
            []

        Just selections ->
            selections
