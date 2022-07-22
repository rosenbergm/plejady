module Login exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Model exposing (Model)
import Msg exposing (Msg(..))


view : Model -> Html Msg
view model =
    div [ class "login" ]
        [ h1 [] [ text "Plejády" ]
        , p [] [ text "Pro přihlášení použijte svoje školní e-maily končící @student.alej.cz." ]
        , p [] [ text "Přihlášky pod jiným e-mailem nejsou možné." ]
        , viewInput "email" "Email" model.email Email -- TODO: temp login
        , button
            [ onClick
                (SignIn
                    { email = model.email
                    , token = ""
                    }
                )
            ]
            [ text "Přihlásit pomocí školního účtu" ]
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []
