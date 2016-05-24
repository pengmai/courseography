{-# LANGUAGE OverloadedStrings #-}
module WebParsing.PostParser
    (getPost) where

import Network.HTTP
import Database.PostInsertion(insertPost, insertPostCategory)
import Database.Persist.Sqlite
import WebParsing.ParsingHelp
import qualified Data.Text as T
import Data.Char
import Text.HTML.TagSoup
import Text.HTML.TagSoup.Match

fasCalendarURL :: String
fasCalendarURL = "http://calendar.artsci.utoronto.ca/"

getPost :: String -> IO ()
getPost str = do
    let path = fasCalendarURL ++ str
    rsp <- simpleHTTP (getRequest path)
    body <- getResponseBody rsp
    let tags = filter isNotComment $ parseTags (T.pack body)
        postsSoup = secondH2 tags
        posts =  partitions isPostName postsSoup
    print $ "parsing " ++ str
    print posts
    where 
        isNotComment (TagComment _) = False
        isNotComment _ = True
        secondH2 tags =
            let sect = sections (isTagOpenName "h2") tags
            in
                if null sect
                then
                    []
                else
                    takeWhile (~/= ("<a name=courses>" :: String)) $ sect !! 1
        isPostName (TagOpen _ attrs) = any (\x -> fst x == "name" && T.length (snd x) == 9) attrs
        isPostName _ = False