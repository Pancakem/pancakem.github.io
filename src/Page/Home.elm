module Page.Home exposing (init, view, Model, update, Msg)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http 
import Types exposing (..)
import Json.Decode as Decode
import RemoteData

init : (Model, Cmd Msg)
init = 
    ({
        posts = RemoteData.Loading
    }
    , loadAllBlogs
    )

-- model 
type alias Model = 
    { posts : WebData (List Content)
    }


-- view
view : Model -> { title : String, content : Html Msg}
view model =
    {title = "Home"
    , content = viewWebData model
    }

viewSnippet : Content -> Html Msg
viewSnippet content = 
    let
        ct = content.blog.content
        tease = String.dropRight ((String.length ct) - 30) ct
    in
    div []
        [ a [href "" ] [text content.blog.title]
        , p [] [text tease ]
        ]

viewWebData : Model -> Html Msg
viewWebData {posts} = 
    case posts of
        RemoteData.Loading ->
            text "Loading..."
        
        RemoteData.NotAsked ->
            text ""
        
        RemoteData.Failure err ->
            text ("Error loading blogs:" ++ Debug.toString err)
        
        RemoteData.Success data ->
            div [] (List.map viewSnippet data)
        


-- update 

type alias WebData a =
      RemoteData.RemoteData Http.Error a

type Msg = 
    Clicked String
    | LoadAllBlogs (WebData (List Content))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Clicked _->
            (model, Cmd.none)
        
        LoadAllBlogs res->
            ({model | posts = res }, Cmd.none)
            
loadAllBlogs : Cmd Msg
loadAllBlogs = 
    Http.get
    { url = url 
    , expect = Http.expectJson (RemoteData.fromResult >> LoadAllBlogs) (Decode.list contentDecoder)
    }

