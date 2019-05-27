module Route exposing (Route(..), fromUrl, pushUrl)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)

type Route = 
    Home
    | Blog String
    | SearchResult String


parser : Parser (Route -> a) a
parser = 
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Blog (s "blog" </> string)
        , Parser.map SearchResult (s "sresult" </> string)
        ]

fromUrl : Url -> Maybe Route 
fromUrl url = 
    Parser.parse parser url


pushUrl : Nav.Key -> Route -> Cmd msg
pushUrl key route = 
    Nav.pushUrl key (toPath route)

toPath : Route -> String
toPath route = 
    let
        path = 
            case route of 
                Home ->
                    [""]
                
                Blog str ->
                    [str]
                
                SearchResult str ->
                    [str]
    in
    String.join "/" path