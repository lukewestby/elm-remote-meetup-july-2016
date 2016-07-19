module Main exposing (..)

import Launchpad exposing (Color, green, red, button, Node, beginnerProgram)


type alias Model =
    Color


model : Model
model =
    green


type Msg
    = Toggle


update : Msg -> Model -> Model
update msg model =
    case msg of
        Toggle ->
            if model == green then
                red
            else
                green


view : Model -> Node Msg
view model =
    button
        { column = 0
        , row = 0
        , color = model
        , on = True
        , onButtonOn = Nothing
        , onButtonOff = Just Toggle
        }


main : Program Never
main =
    beginnerProgram
        { model = model
        , update = update
        , view = view
        }
