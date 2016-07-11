module CustomButton exposing (Model, model, Msg, update, view, subscriptions)

import Launchpad exposing (Node, button, green, lowRed)


type alias Model =
    Bool


model : Model
model =
    False


type Msg
    = Toggle


update : Msg -> Model -> Model
update msg model =
    case msg of
        Toggle ->
            not model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Int -> Int -> Model -> Node Msg
view row column model =
    button
        { row = row
        , column = column
        , on = True
        , onButtonOn = Just Toggle
        , onButtonOff = Just Toggle
        , color =
            if model then
                green
            else
                lowRed
        }
