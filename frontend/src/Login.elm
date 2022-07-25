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
        , input [ type_ "email", placeholder "Email", value model.email, onInput Email ] [] -- TODO: temp login
        , button
            [ onClick <| SignIn model.email ]
            [ text "Přihlásit pomocí školního účtu" ]
        ]
