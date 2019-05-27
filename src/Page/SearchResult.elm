module Page.SearchResult exposing (..)

import Types
import Http
import Json.Decode exposing (list)
import Html exposing (Html, div)


init : String -> (Model, Cmd Msg)
init tag = 
    (Model []
    , getAllTagRelatedBlogs tag
    )

type alias Model = 
    { posts : List Types.Content
    }


type Msg = 
    LoadResults (Result Http.Error (List Types.Content))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadResults res ->
            let
                newModel = 
                    case res of
                        Ok conts ->
                            {model | posts = conts}
                        
                        Err _ ->
                            model
            in
            ( newModel, Cmd.none )

        
getAllTagRelatedBlogs : String -> Cmd Msg
getAllTagRelatedBlogs str = 
    Http.get
    { url = ""
    , expect = Http.expectJson LoadResults (list Types.contentDecoder)
    } 

view : Model -> { title: String, content : Html Msg }
view model = 
    { title = "Results"
    , content = div [] []
    }