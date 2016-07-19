module Launchpad
    exposing
        ( programWithFlags
        , program
        , beginnerProgram
        , staticProgram
        , map
        , Node
        , group
        , button
        , Color
        , lowRed
        , red
        , lowAmber
        , amber
        , yellow
        , lowGreen
        , green
        )

import Native.Launchpad


type Color
    = Color String


lowRed : Color
lowRed =
    Color "low-red"


red : Color
red =
    Color "red"


lowAmber : Color
lowAmber =
    Color "low-amber"


amber : Color
amber =
    Color "amber"


yellow : Color
yellow =
    Color "yellow"


lowGreen : Color
lowGreen =
    Color "low-green"


green : Color
green =
    Color "green"


type Node msg
    = Node


button :
    { color : Color
    , on : Bool
    , row : Int
    , column : Int
    , onButtonOn : Maybe msg
    , onButtonOff : Maybe msg
    }
    -> Node msg
button =
    Native.Launchpad.button


group : List (Node msg) -> Node msg
group =
    Native.Launchpad.group


map : (childMsg -> parentMsg) -> Node childMsg -> Node parentMsg
map =
    Native.Launchpad.map


programWithFlags :
    { init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> Node msg
    }
    -> Program flags
programWithFlags =
    Native.Launchpad.programWithFlags


program :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> Node msg
    }
    -> Program Never
program app =
    programWithFlags { app | init = always app.init }


beginnerProgram :
    { model : model
    , update : msg -> model -> model
    , view : model -> Node msg
    }
    -> Program Never
beginnerProgram app =
    program
        { init = ( app.model, Cmd.none )
        , update = \msg model -> ( app.update msg model, Cmd.none )
        , view = app.view
        , subscriptions = always Sub.none
        }


staticProgram : Node msg -> Program Never
staticProgram node =
    beginnerProgram
        { model = ()
        , update = \_ _ -> ()
        , view = \_ -> node
        }
