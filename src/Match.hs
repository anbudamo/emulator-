module Match where 

import Data.Either (isRight)
import Text.Parsec
import Text.Parsec.String

-- returns a parser that parses a string containing 'term'
-- later realized I can use isInfix from Data.List, but I would
-- probably want to use Parsec in the future anyways 
containsP :: String -> Parser String 
containsP term =
    try (string term) <|> do 
        _ <- anyChar
        containsP term

matchFilter :: String -> String -> Either ParseError String 
matchFilter term target = parse (containsP term) "" target 

isMatch :: String -> String -> Bool
isMatch term target = isRight $ matchFilter term target  