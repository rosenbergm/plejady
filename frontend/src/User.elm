module User exposing (..)


type alias User =
    { email : String
    , token : String
    }


createUser : String -> User
createUser email =
    { email = email, token = "" }
