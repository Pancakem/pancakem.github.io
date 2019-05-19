module Page.Blog exposing (..)

import Html exposing (Html)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Types


type alias Model =
    { content : Types.Content
    }


type Msg = 
    ClickedTag String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedTag _ ->
            ( model, Cmd.none )


view : Model -> {title: String, content: Html Msg}
view model = 
    {title = model.content.blog.title
    , content = layout [] <| viewBlog model
    }

viewBlog : Model -> Element Msg
viewBlog {content} =
    Element.paragraph []
    [Element.el[] (viewTitle content.blog.title )
    , Element.el[] (viewBody content.blog.content)
    , Element.el[] (viewTags content.tags)
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
                ta = 
                    case tag of
                        Types.Tag st ->
                            st
            in
            el[]
                (text ("# " ++ ta))
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

