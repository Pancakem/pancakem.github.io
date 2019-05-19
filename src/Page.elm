module Page exposing (..)

import Browser exposing (Document)
import Html exposing (..)

type Page = 
    Home
    | Blog

view : Page -> { title : String, content : Html msg } -> Document msg
view page { title, content } =
    { title = title
    , body = content :: []
    }

-- viewHeader : Html msg
-- viewHeader = 
