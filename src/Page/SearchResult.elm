module Page.SearchResult exposing (Model, Msg, init, update, view)

import Types
import Http
import Json.Decode exposing (list)
import Html exposing (Html, div, text, a, p)
import Html.Attributes exposing (href)
import RemoteData


init : String -> (Model, Cmd Msg)
init tag = 
    (Model RemoteData.Loading
    , getAllTagRelatedBlogs tag
    )

type alias Model = 
    { posts : Types.WebData (List Types.Content)
    }


type Msg = 
    LoadResults (Types.WebData (List Types.Content))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadResults res ->
            ( {model | posts = res}, Cmd.none )

        
getAllTagRelatedBlogs : String -> Cmd Msg
getAllTagRelatedBlogs str = 
    Http.get
    { url = ""
    , expect = Http.expectJson (RemoteData.fromResult >> LoadResults) (list Types.contentDecoder)
    } 

view : Model -> { title: String, content : Html Msg }
view model = 
    { title = "Results"
    , content = viewWebData model
    }

viewWebData : Model -> Html Msg
viewWebData {posts} = 
    case posts of
        RemoteData.Loading ->
            text "Loading..."

        RemoteData.NotAsked ->
            text ""

        RemoteData.Failure err ->
            text ("Error searching: " ++ Debug.toString err)
        
        RemoteData.Success data ->
            div [] (List.map viewSnippet data)

viewSnippet : Types.Content -> Html Msg
viewSnippet content = 
    let
        ct = content.blog.content
        tease = String.dropRight ((String.length ct) - 30) ct
    in
    div []
        [ a [href "" ] [text content.blog.title]
        , p [] [text tease ]
        ]