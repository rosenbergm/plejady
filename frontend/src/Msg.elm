module Msg exposing (Msg(..))

import Talks exposing (Talk)


type Msg
    = SelectTalk Talk
    | Email String -- TODO: temp login
    | SignIn String
    | SignOut
