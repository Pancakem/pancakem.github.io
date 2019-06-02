module Page.Blog exposing (Model, Msg, init, update, view)

import Html exposing (Html)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Region as Region
import Types
import Http
import RemoteData


init : String -> (Model, Cmd Msg)
init str = 
    ({content = RemoteData.Loading }
    , loadBlog str -- use this command to load blog with said title
    )

type alias Model =
    { content : Types.WebData (Types.Content)
    }


type Msg = 
    ClickedTag String
    | LoadBlog (Types.WebData (Types.Content))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedTag _ ->
            ( model, Cmd.none )
        
        LoadBlog res ->
            ({model | content = res }, Cmd.none)

loadBlog : String ->  Cmd Msg
loadBlog str = 
    let
        builtURL = "" ++ str
    in
    Http.get
    { url = builtURL
    , expect = Http.expectJson (RemoteData.fromResult >> LoadBlog) Types.contentDecoder
    }

-- views

view : Model -> {title: String, content: Html Msg}
view model = 
    let
        (ttle, elem) = viewWebData model
    in
    
    {title = ttle
    , content = layout [] <| elem
    }

viewBlog : Types.Content -> Element Msg
viewBlog cont =
            Element.column 
            [ height fill
            , width <| fillPortion 1
            , paddingXY 0 10
            ]
            [Element.el[] (viewTitle cont.blog.title )
            , Element.el[] (viewBody cont.blog.content)
            , Element.el[] (viewTags cont.tags)
            ]

viewBody : String ->  Element Msg
viewBody str = 
    let
        ct = str
        firstLetter = String.left 1 ct
        restofText = String.right ((String.length ct) - 1) ct
    in
    
    Element.paragraph []
    [ Element.el
        [ Element.alignLeft
        , Element.padding 5
        ]
        (Element.text firstLetter)
    , Element.text restofText
    ]

viewTitle  : String -> Element Msg
viewTitle str = 
    Element.el
        [ Font.color (Element.rgb 0 0 1)
        , Font.size 18
        , Region.heading 1
        , Font.family
            [ Font.typeface "Open Sans"
            , Font.sansSerif
            ]
        ]
        (Element.text str)

viewTags : List Types.Tag -> Element Msg
viewTags lisTag = 
    let
        activeTagAttrs =
            [ Background.color <| rgb255 117 179 201, Font.bold ]

        tagAttrs =
            [ paddingXY 15 5, width fill ]

        tagEl tag =
            let
                ta = Types.retrieveTagString tag
            in
            el[]
                (Element.text ("# " ++ ta))
    in
    column
        [ height fill
        , width <| fillPortion 1
        , paddingXY 0 10
        , Background.color <| rgb255 92 99 118
        , Font.color <| rgb255 255 255 255
        ]
    <|
        List.map tagEl lisTag

viewWebData : Model -> (String, Element Msg)
viewWebData {content} = 
    case content of
        RemoteData.Loading ->
            ("Blog", Element.text "Loading...")

        RemoteData.NotAsked ->
            ("Blog", Element.text "")

        RemoteData.Failure err ->
            ("Error", Element.text ("Error loading blog: " ++ Debug.toString err))
        
        RemoteData.Success data ->
            ( data.blog.title , (viewBlog data))