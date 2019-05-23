module Types exposing (Tag, Blog, PublishDate, Content, createTag,
                        createPublishDate, retrieveDateString, 
                        retrieveTagString)

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
