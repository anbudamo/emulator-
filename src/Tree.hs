module Tree where 

import System.Directory (doesDirectoryExist, listDirectory)
import System.FilePath (takeFileName)
import Data.List (isPrefixOf)

-- type FilePath = String (default from Prelude)
data DirTree a = Node a [DirTree a] 

instance Show a => Show (DirTree a) where
  show (Node r xs) = "Node " ++ show r ++ " [" ++ unwords (map show xs) ++ "]"

sampleTree :: DirTree String 
sampleTree = 
  Node "/" [Node "Documents" [Node "attachments" [], Node "final.docx" []], Node "Downloads" [Node "tree.png" []], Node "python.exe" []]

isDirectoryEmpty :: FilePath -> IO Bool 
isDirectoryEmpty path = do 
  contents <- listDirectory path
  return (null contents)

listVisibleDirectory :: FilePath -> IO [FilePath]
listVisibleDirectory path = do 
  contents <- listDirectory path
  return [f | f <- contents, not ("." `isPrefixOf` f)]

listDirectoryAsPaths :: FilePath -> IO [FilePath]
listDirectoryAsPaths path = do 
  contents <- listVisibleDirectory path
  let prefix = path ++ "/"
  let paths = map (prefix ++) contents
  return paths 

buildTreeFromPath :: FilePath -> IO (DirTree FilePath)
buildTreeFromPath path = do
  let filename = takeFileName path
  isDir <- doesDirectoryExist path
  isDirEmpty <- if isDir then isDirectoryEmpty path else return True
  let isLeafNode = not isDir || isDirEmpty 
  case isLeafNode of 
    True -> return (Node filename [])
    False -> do 
      childPaths <- listDirectoryAsPaths path
      children <- mapM buildTreeFromPath childPaths 
      return (Node filename children)

determinePrefix :: [DirTree FilePath] -> String 
determinePrefix children = 
    case children of 
        [] -> ""
        [child] -> "|\n`--" 
        otherwise -> "|--"

prettyPrint :: DirTree FilePath -> IO ()
prettyPrint (Node name children) = do 
    putStrLn name 
    printChildren "" children 
    -- print x directories, x files


printChildren :: String -> [DirTree FilePath] -> IO ()
printChildren _ [] = return ()
printChildren prefix [lastChild] = printNode True prefix lastChild 
printChildren prefix (c:cs) = do 
    printNode False prefix c
    printChildren prefix cs

printNode :: Bool -> String -> DirTree FilePath -> IO ()
printNode isLast prefix (Node name children) = do 
    let tie = if isLast then "`-- " else "|-- " 
    putStrLn (prefix ++ tie ++ name) 

    let extension = if isLast then "   " else "|   "
    let childPrefix = prefix ++ extension
    printChildren childPrefix children

-- prettyPrint :: DirTree FilePath -> IO ()
-- prettyPrint (Node name children) = do 
--     let prefix = determinePrefix children 
--     putStrLn name 
--     putStrLn "|"
--     putStr "`--"
--     mapM_ (\child -> prettyPrintHelper child prefix) children
--     return ()
--     -- prettyPrintHelper tree 0
--     putStrLn ""

-- prettyPrintHelper :: DirTree FilePath -> String -> IO ()
-- prettyPrintHelper (Node name []) prefix = do 
-- --   let indent = replicate (height*3) ' '
-- --   putStrLn (indent ++ "|")
-- --   putStr (indent ++ "`--")
--   putStr prefix
--   putStrLn (" " ++ name)
--   return ()
-- prettyPrintHelper (Node name [child]) prefix = do 
-- --   let indent = replicate (height*3) ' '
-- --   putStrLn (indent ++ "|")
-- --   putStr (indent ++ "`--")
--   putStr prefix
--   putStrLn (" " ++ name)
--   prettyPrintHelper child "   |\n`--"
--   return ()
-- prettyPrintHelper (Node name children) prefix = do 
-- --   let indent = replicate (height*3) ' '
-- --   putStrLn (indent ++ "|")
-- --   putStr (indent ++ "`--")
--   putStr prefix
--   putStrLn (" " ++ name)
--   mapM_ (\child -> prettyPrintHelper child "|   |--") children 
--   return ()



-- prettyPrint :: DirTree FilePath -> IO ()
-- prettyPrint tree = do 
--   prettyPrintHelper tree 0
--   putStrLn ""

-- prettyPrintHelper :: DirTree FilePath -> Int -> IO ()
-- prettyPrintHelper (Node name []) height = do 
--   let indent = replicate (height*3) ' '
--   putStrLn (" " ++ name)
--   putStrLn (indent ++ " |")
--   putStr (indent ++ " `--")
--   return ()
-- prettyPrintHelper (Node name children) height = do 
--   let indent = replicate (height*3) ' '
--   putStrLn (" " ++ name)
--   putStrLn (indent ++ " |")
--   putStr (indent ++ " `--")
--   mapM_ (\child -> prettyPrintHelper child (height+1)) children 
--   return ()

updateRoot :: String -> DirTree String -> DirTree String
updateRoot item (Node rootItem children) = Node item children
