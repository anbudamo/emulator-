module Tree where 

import System.Directory (doesDirectoryExist, listDirectory)
import System.FilePath (takeFileName)
import Data.List (isPrefixOf)
import Exceptions

-- type FilePath = String (default from Prelude)
data DirTree a = Folder a [DirTree a] | File a 

instance Show a => Show (DirTree a) where
  show (Folder r xs) = "Folder " ++ show r ++ " [" ++ unwords (map show xs) ++ "]"
  show (File r) = "File " ++ show r

sampleTree :: DirTree String 
sampleTree = 
  Folder "/" [Folder "Documents" [Folder "attachments" [], File "final.docx"], Folder "Downloads" [File "tree.png"], File "python.exe"]

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

updateRoot :: String -> DirTree String -> DirTree String
updateRoot item (Folder _ children) = Folder item children
updateRoot item (File _) = File item

maxHeight :: DirTree a -> Int 
maxHeight tree = undefined

buildTreeFromPath :: FilePath -> IO (DirTree FilePath)
buildTreeFromPath path = do
  let filename = takeFileName path
  isDir <- doesDirectoryExist path
  isDirEmpty <- if isDir then isDirectoryEmpty path else return True
  let isLeafNode = not isDir || isDirEmpty 
  case isLeafNode of 
    True -> if isDir then return (Folder filename []) else return (File filename)
    False -> do 
      childPaths <- listDirectoryAsPaths path
      children <- mapM buildTreeFromPath childPaths 
      return (Folder filename children)

prettyPrint :: DirTree FilePath -> IO ()
prettyPrint (Folder name children) = do 
    putStrLn name 
    printChildren "" children 
    -- print x directories, x files
    let count = countTree (Folder name children)
    -- format count output based on plurality (is that a word lol)
    case count of 
        (1, 1) -> putStrLn "\n1 directory, 1 file"
        (1, fileCount) -> putStrLn ("\n1 directory, " ++ (show fileCount) ++ " files")
        (folderCount, 1) -> putStrLn ("\n" ++ (show folderCount) ++ " directories, " ++ " 1 file")
        (folderCount, fileCount) -> putStrLn ("\n" ++ (show folderCount) ++ " directories, " ++ (show fileCount) ++ " files")
prettyPrint (File name) = do 
    putStrLn (name ++ "\t [error opening dir]")
    putStrLn ""
    putStrLn "0 directories, 1 file"

printChildren :: String -> [DirTree FilePath] -> IO ()
printChildren _ [] = return ()
printChildren prefix [lastChild] = printNode True prefix lastChild 
printChildren prefix (c:cs) = do 
    printNode False prefix c
    printChildren prefix cs

printNode :: Bool -> String -> DirTree FilePath -> IO ()
printNode isLast prefix (Folder name children) = do 
    let tie = if isLast then "`-- " else "|-- " 
    putStrLn (prefix ++ tie ++ name) 
    let extension = if isLast then "   " else "|   "
    let childPrefix = prefix ++ extension
    printChildren childPrefix children
printNode isLast prefix (File name) = do 
    let tie = if isLast then "`-- " else "|-- " 
    putStrLn (prefix ++ tie ++ name) 

-- traversal functions
-- normally they should return [a], but for my countTree function I wanted to 
-- be able to flatten into [DirTree a] where each element consists of only a root
-- eg: what inorder whould normally look like (might be useful for a feature in the future)
-- inorder :: Show a => DirTree a -> [a]
-- inorder (Folder name (entry:entries)) =
--     inorder entry ++ [name] ++ concat (map inorder entries)
-- inorder (Folder name []) =
--     [name]
-- inorder (File name) = 
--     [name]
preorder :: Show a => DirTree a -> [DirTree a]
preorder = undefined 
inorder :: Show a => DirTree a -> [DirTree a]
inorder (Folder name (entry:entries)) =
    inorder entry ++ [Folder name []] ++ concat (map inorder entries)
inorder (Folder name []) =
    [Folder name []]
inorder (File name) = 
    [File name]
postorder :: Show a => DirTree a -> [DirTree a]
postorder = undefined 

-- flatten can use any type of traversal
flattenTree :: DirTree a -> (DirTree a -> [DirTree a]) -> [DirTree a]
flattenTree tree order = order tree

countTree :: Show a => DirTree a -> (Int, Int)
countTree tree = 
    countFlatTree flatTlist (0,0)
    where flatTlist = catch flattenTree tree inorder

-- returns tuple (number of dirs, number of files) given a flat [DirTree a]
countFlatTree :: [DirTree a] -> (Int, Int) -> (Int, Int)
countFlatTree (entry:entries) (numDirs, numFiles) = 
    case entry of 
        (Folder _ []) -> countFlatTree entries (numDirs+1, numFiles)
        (File _) -> countFlatTree entries (numDirs, numFiles+1)
        -- all entries must be flat since constFlatTree expects a flat list
        otherwise -> error "countFlatTree received a nested folder"
countFlatTree [] count = count