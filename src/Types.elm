module Types exposing (Tag, Blog, PublishDate, Content, WebData,
                        createTag, createPublishDate, retrieveDateString, 
                        retrieveTagString, contentDecoder, url)

import Json.Decode exposing (..)
import RemoteData
import Http exposing (..)

type Tag = Tag String

createTag : String -> Tag
createTag str = 
    Tag str

retrieveTagString : Tag -> String
retrieveTagString (Tag tag) = 
    tag
    
type alias Blog = 
    {title : String
    , content : String 
    }

type PublishDate = PublishDate String

createPublishDate : String -> PublishDate
createPublishDate str = 
    PublishDate str

retrieveDateString : PublishDate -> String
retrieveDateString (PublishDate pd) =
    pd

type alias Content = 
    { publishedDate : PublishDate
    , blog : Blog
    , tags : List Tag
    }

-- json structure
-- [
--   {
--     "blog": {
--       "title": "",
--       "content": ""
--     }
--   }
-- ]

blogDecoder : Decoder Blog
blogDecoder = 
    map2 Blog 
        (field "title" string )
        (field "content" string)

publishDateDecoder : String -> Decoder PublishDate
publishDateDecoder datestr =
   succeed (createPublishDate datestr)
    
tagDecoder : List String -> Decoder (List Tag)
tagDecoder tagstrs = 
    succeed (List.map createTag tagstrs)

contentDecoder : Decoder Content
contentDecoder = 
    map3 Content
        (field "publishDate" string |> andThen publishDateDecoder)
        (field "blog" blogDecoder)
        (field "tags" (list string) |> andThen tagDecoder )

url : String
url = 
    ""

type alias WebData a =
    RemoteData.RemoteData Http.Error a