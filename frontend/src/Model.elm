module Model exposing (..)

import Dict exposing (Dict)
import Talks exposing (Room, Talk, TimeBlock)
import User exposing (User)


type alias Model =
    { user : Maybe User
    , email : String -- TODO: temp login
    , selections : List String
    , selectionsDb : Dict String (List String) --TODO: save in API
    , rooms : List Room
    , timeBlocks : List TimeBlock
    , talks : List Talk
    }
