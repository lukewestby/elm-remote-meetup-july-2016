module SlackButton exposing (Model, model, Msg, initialize, update, subscriptions, view)

import Task
import Json.Decode as Decode exposing (Decoder)
import HttpBuilder exposing (..)
import Time exposing (Time)
import Launchpad exposing (Node, button, green, amber, lowAmber, red)


-- MODEL


type LoadState
    = Initial
    | Loading
    | Success
    | Failure


type alias Model =
    { loadState : LoadState
    , lastToggle : Time
    , flashOn : Bool
    , token : String
    }


model : String -> Model
model =
    Model Initial 0 True



-- UPDATE


type Msg
    = PostToSlack Int Int
    | PostSuccess
    | PostFailure
    | Tick Time


initialize : Cmd Msg
initialize =
    let
        never n =
            never n
    in
        Task.perform never Tick Time.now


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PostToSlack row column ->
            ( { model | loadState = Loading }
            , postToSlack row column model.token
            )

        PostSuccess ->
            ( { model | loadState = Success }
            , Cmd.none
            )

        PostFailure ->
            ( { model | loadState = Failure }
            , Cmd.none
            )

        Tick time ->
            if model.lastToggle == 0 then
                ( { model | lastToggle = time }
                , Cmd.none
                )
            else if (time - model.lastToggle) >= (0.25 * Time.second) then
                ( { model | lastToggle = time, flashOn = not model.flashOn }
                , Cmd.none
                )
            else
                model ! []



-- COMMANDS


decodeSlackSuccess : Decoder Bool
decodeSlackSuccess =
    Decode.at [ "ok" ] Decode.bool


handleSlackResponse : Bool -> Msg
handleSlackResponse ok =
    if ok then
        PostSuccess
    else
        PostFailure


postToSlack : Int -> Int -> String -> Cmd Msg
postToSlack row column token =
    let
        slackUrl =
            HttpBuilder.url ("https://slack.com/api/chat.postMessage")
                [ ( "token", token )
                , ( "channel", "@slackbot" )
                , ( "text", ("Hello from the button at " ++ (toString ( row, column ))) )
                , ( "username", "@luke" )
                , ( "as_user", "true" )
                ]
    in
        get slackUrl
            |> send (jsonReader decodeSlackSuccess) stringReader
            |> Task.map .data
            |> Task.perform (always PostFailure) handleSlackResponse



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.loadState of
        Loading ->
            Time.every 50 Tick

        _ ->
            Sub.none



-- VIEW


view : Int -> Int -> Model -> Node Msg
view row column model =
    let
        onButtonOff =
            case model.loadState of
                Loading ->
                    Nothing

                _ ->
                    Just <| PostToSlack row column

        color =
            case model.loadState of
                Success ->
                    green

                Failure ->
                    red

                Initial ->
                    amber

                Loading ->
                    if model.flashOn then
                        amber
                    else
                        lowAmber
    in
        button
            { row = row
            , column = column
            , on = True
            , onButtonOff = onButtonOff
            , onButtonOn = Nothing
            , color = color
            }
