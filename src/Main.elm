module Main exposing (Model, Msg, update, view, subscriptions, init)

import Html exposing (..)
import Browser
import Browser.Navigation exposing (..)
import Page.Home as Home
import Types exposing (..)
import Url
import Page
import Page.Blog as PBlog

init : () -> Url.Url -> Key -> (Model, Cmd Msg)
init _ url _ = 
    -- (Home {posts = [testContent]}, Cmd.none)
    (BlogModel {content = testContent}, Cmd.none)

main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        , subscriptions = subscriptions
    }

testContent : Content
testContent = 
    Content (PublishDate "19-05-2019") (Blog "First Blog" cont) ([Tag "test"])

type Model =
    Home Home.Model
    | BlogModel PBlog.Model


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | BlogMsg PBlog.Msg
    | SelectBlog String



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case (msg, model) of
        (HomeMsg subMsg, Home home)  ->
            Home.update subMsg home 
                |> updateWith Home HomeMsg model
    
        (SelectBlog str, _) ->
            (model, Cmd.none)

        (LinkClicked _, _) ->
            (model, Cmd.none)

        (UrlChanged _, _) ->
            (model, Cmd.none)

        (BlogMsg subMsg, BlogModel mod) ->
            (model, Cmd.none)
        
        (_, _) ->
            (model, Cmd.none)


view : Model -> Browser.Document Msg
view model =
    let
         viewPage page toMsg config =
            let
                { title, body } =
                    Page.view page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Home mod ->
            viewPage Page.Home HomeMsg (Home.view mod)
        
        BlogModel mod ->
            viewPage Page.Blog BlogMsg (PBlog.view mod)
            

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )

cont = """An example of a simple mechanism that can be modeled by a state machine is a turnstile.[3][4] A turnstile, used to control access to subways and amusement park rides, is a gate with three rotating arms at waist height, one across the entryway. Initially the arms are locked, blocking the entry, preventing patrons from passing through. Depositing a coin or token in a slot on the turnstile unlocks the arms, allowing a single customer to push through. After the customer passes through, the arms are locked again until another coin is inserted.

Considered as a state machine, the turnstile has two possible states: Locked and Unlocked.[3] There are two possible inputs that affect its state: putting a coin in the slot (coin) and pushing the arm (push). In the locked state, pushing on the arm has no effect; no matter how many times the input push is given, it stays in the locked state. Putting a coin in – that is, giving the machine a coin input – shifts the state from Locked to Unlocked. In the unlocked state, putting additional coins in has no effect; that is, giving additional coin inputs does not change the state. However, a customer pushing through the arms, giving a push input, shifts the state back to Locked.

The turnstile state machine can be represented by a state transition table, showing for each possible state, the transitions between them (based upon the inputs given to the machine) and the outputs resulting from each input:"""