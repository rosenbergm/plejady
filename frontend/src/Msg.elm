module Msg exposing (Msg(..))

import Model exposing (User)


type Msg
    = SelectTalk String
    | Email String -- TODO: temp login
    | SignIn User
    | SignOut
