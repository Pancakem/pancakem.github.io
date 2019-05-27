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

-- json structure
-- [
--   {
--     "blog": {
--       "title": "",
--       "content": ""
--     }
--   }
-- ]

blogDecoder : Decode.Decoder Types.Blog
blogDecoder = 
    Decode.map2 Types.Blog 
        (Decode.field "title" Decode.string )
        (Decode.field "content" Decode.string)

publishDateDecoder : String -> Decode.Decoder Types.PublishDate
publishDateDecoder datestr =
   Decode.succeed (createPublishDate datestr)
    
tagDecoder : List String -> Decode.Decoder (List Types.Tag)
tagDecoder tagstrs = 
    Decode.succeed (List.map createTag tagstrs)

contentDecoder : Decode.Decoder Types.Content
contentDecoder = 
    Decode.map3 Types.Content
        (Decode.field "publishDate" Decode.string |> Decode.andThen publishDateDecoder)
        (Decode.field "blog" blogDecoder)
        (Decode.field "tags" (Decode.list Decode.string) |> Decode.andThen tagDecoder )

            
loadAllBlogs : Cmd Msg
loadAllBlogs = 
    Http.get
    { url = url 
    , expect = Http.expectJson LoadAllBlogs (Decode.list contentDecoder)
    }

url : String
url = 
    ""