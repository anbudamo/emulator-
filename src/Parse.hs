module Parse where 

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