module Main exposing (..)

import Launchpad exposing (Node)
import Dict exposing (Dict)
import SlackButton


-- MODEL


type alias Model =
    { slackButtons : Dict ( Int, Int ) SlackButton.Model
    }


model : String -> Model
model token =
    { slackButtons =
        [0..7]
            |> List.map (\value -> List.map ((,) value) [0..7])
            |> List.concat
            |> List.map (\value -> ( value, SlackButton.model token ))
            |> Dict.fromList
    }



-- UPDATE


type Msg
    = SlackButtonMsg ( Int, Int ) SlackButton.Msg


initialize : Model -> Cmd Msg
initialize model =
    model.slackButtons
        |> Dict.keys
        |> List.map (\location -> Cmd.map (SlackButtonMsg location) SlackButton.initialize)
        |> Cmd.batch


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SlackButtonMsg location subMsg ->
            case Dict.get location model.slackButtons of
                Just subModel ->
                    let
                        ( nextSubModel, subCmd ) =
                            SlackButton.update subMsg subModel
                    in
                        ( { model | slackButtons = Dict.insert location nextSubModel model.slackButtons }
                        , Cmd.map (SlackButtonMsg location) <| subCmd
                        )

                Nothing ->
                    model ! []



-- VIEW


viewButton : ( ( Int, Int ), SlackButton.Model ) -> Node Msg
viewButton ( location, model ) =
    SlackButton.view (fst location) (snd location) model
        |> Launchpad.map (SlackButtonMsg location)


view : Model -> Node Msg
view model =
    model.slackButtons
        |> Dict.toList
        |> List.map viewButton
        |> Launchpad.group



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    model.slackButtons
        |> Dict.toList
        |> List.map (\( location, subModel ) -> Sub.map (SlackButtonMsg location) (SlackButton.subscriptions subModel))
        |> Sub.batch



-- PROGRAM


type alias Flags =
    { slackToken : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        initModel =
            model flags.slackToken
    in
        ( initModel, initialize initModel )


main : Program Flags
main =
    Launchpad.programWithFlags
        { view = view
        , update = update
        , init = init
        , subscriptions = subscriptions
        }
