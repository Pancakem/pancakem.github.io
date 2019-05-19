module Types exposing (..)


type Tag = Tag String

type alias Blog = 
    {title : String
    , content : String 
    }

type PublishDate = PublishDate String

type alias Content = 
    { publishedDate : PublishDate
    , blog : Blog
    , tags : List Tag
    }

