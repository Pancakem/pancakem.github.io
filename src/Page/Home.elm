module Page.Home exposing (init, view, Model, update, Msg)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http 
import Types exposing (..)
import Json.Decode as Decode

init : (Model, Cmd Msg)
init = 
    ({
        posts = []
    }
    , loadAllBlogs
    )
-- model 

type alias Model = 
    { posts : List Content
    }


-- view

view : Model -> { title : String, content : Html Msg}
view model =
    {title = "Home"
    , content = div [] (List.map viewSnippet model.posts)
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

-- update 

type Msg = 
    Clicked String
    | LoadAllBlogs (Result Http.Error (List Content))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Clicked _->
            (model, Cmd.none)
        
        LoadAllBlogs blogs->
            (model, Cmd.none)
            
loadAllBlogs : Cmd Msg
loadAllBlogs = 
    Http.get
    { url = url 
    , expect = Http.expectJson LoadAllBlogs (Decode.list contentDecoder)
    }

