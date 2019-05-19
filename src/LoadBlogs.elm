module LoadBlogs exposing (..)

import File 
import File.Select exposing (file)
import Bytes
import Task
import Bytes.Decode as Decode

type Msg = 
    BlogZipRequested 
    | BlogZipSelected File.File
    | BlogZipLoaded Bytes.Bytes

type alias Model = 
    {fileContent : List String
    }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BlogZipRequested ->
            ( model, requestZip )

        BlogZipLoaded bytes ->
            ( model, Cmd.none )

        BlogZipSelected f ->
            ( model, read f )
     

read : File.File -> Cmd Msg 
read file = 
    Task.perform BlogZipLoaded (File.toBytes file)

requestZip : Cmd Msg
requestZip = 
    file ["application/zip"] BlogZipSelected

list : Decode.Decoder String -> Decode.Decoder (List String)
list decoder =
  Decode.unsignedInt32 Bytes.BE
    |> Decode.andThen (\len -> Decode.loop (len, []) (listStep decoder))

listStep : Decode.Decoder a -> (Int, List a) -> Decode.Decoder (Decode.Step (Int, List a) (List a))
listStep decoder (n, xs) =
  if n <= 0 then
    Decode.succeed (Decode.Done xs)
  else
    Decode.map (\x -> Decode.Loop (n - 1, x :: xs)) decoder