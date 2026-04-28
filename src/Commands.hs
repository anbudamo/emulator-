module Commands where 

import System.Directory (getHomeDirectory, doesPathExist, doesDirectoryExist, renamePath)
-- import System.IO (hFlush, stdout)
import System.IO (hSetBuffering, hSetEcho, stdin, stdout, hFlush, BufferMode(NoBuffering), BufferMode(LineBuffering))
import System.FilePath (takeDirectory, takeBaseName, (</>))
import Text.Read (readMaybe)
import Data.Char
import State
-- import Tree
import Tree1

-- utility function
safeHead :: [a] -> Maybe a
safeHead [] = Nothing  
safeHead (x:_) = (Just x)

-- shave off last entry of path to return parent dirs path (used for command 'cd ..')
-- uses api System.FilePath.takeDirectory
takeWorkingDirectory :: WorkingDirectory -> WorkingDirectory
takeWorkingDirectory (WorkingDirectory currPath) = WorkingDirectory (takeDirectory currPath)

-- command functions
handleCommand :: [String] -> EmulatorState -> IO EmulatorState
handleCommand [] eState = return eState
handleCommand (cmd:args) eState = do 
    newState <- case cmd of 
        "help" -> do 
            if null args 
                then help 
                else putStrLn "help: too many arguments"
            return eState 
        "tree" -> do 
            tree eState args
            return eState 
        "cd" -> do 
            cd args eState
        "mv" -> do 
            mv args eState
        "history" -> do 
            if null args 
                then do
                    history eState
                else do 
                    putStrLn "history: too many arguments"
                    return eState
        _ -> do 
            inputNotRecognized cmd 
            return eState 
    
    -- update state's memory 
    if cmd == "history" 
        then return newState
        else do
            let fullCommand = unwords (cmd:args)
            let oldMem = memory newState 
            let newMem = if length oldMem >= memoryCapacity 
                then tail oldMem ++ [fullCommand]
                else oldMem ++ [fullCommand]
            return newState{memory=newMem}

-- to convert user input line into list of words
parseCommand :: String -> [String] 
parseCommand command = words command 

help :: IO () 
help = do 
    putStrLn "Run basic commands in this custom haskell based terminal emulator:"
    putStrLn "1. cd [optional: path]\n2. mv [old path] [new path]\n3. tree [optional: path]\n4. history\n5. quit"
    return ()

inputNotRecognized :: String -> IO () 
inputNotRecognized input = do 
    putStrLn ("shell: command not found: " ++ input)
    return ()

tree :: EmulatorState -> [String] -> IO () 
-- basic 'tree' with no arg
tree eState [] = do 
    let (WorkingDirectory currPath) = workingDir eState
    fileTree <- buildTreeFromPath currPath
    let newFileTree = updateRoot "." fileTree
    prettyPrint newFileTree 
-- 'tree' with arg
tree eState [arg] = do 
    let (WorkingDirectory currPath) = workingDir eState
    let targetPath = currPath </> arg
    isEntry <- doesPathExist targetPath
    if not isEntry then do 
        putStrLn ("tree: path does not exist: " ++ arg)
        return ()
    else do 
        fileTree <- buildTreeFromPath targetPath
        prettyPrint fileTree 
-- 'tree' with too many args
tree _ _ = do 
    putStrLn ("tree: too many arguments")

cd :: [String] -> EmulatorState -> IO EmulatorState
cd [] eState = do 
    home <- getHomeDirectory
    return eState{workingDir=WorkingDirectory home}
cd [target] eState
    | target == "." = return eState
    | target == ".." = return eState{workingDir=takeWorkingDirectory (workingDir eState)}
    | otherwise = do
        cdHelper target eState
cd _ location = do 
    putStrLn "cd: too many arguments"
    return location

cdHelper :: String -> EmulatorState -> IO EmulatorState
cdHelper arg eState = do
    let (WorkingDirectory currPath) = workingDir eState
    -- (</>) FilePath combine operator from System.FilePath
    let targetDir = currPath </> arg 
    isEntry <- doesPathExist targetDir
    isDir <- doesDirectoryExist targetDir 
    if not isEntry then do
        putStrLn ("cd: no such file or directory: " ++ targetDir) 
        return eState 
    else if not isDir then do
        putStrLn ("cd: not a directory: " ++ targetDir)
        return eState 
    else 
        return eState{workingDir=WorkingDirectory targetDir}

-- mv only moves file to file or directory to directory
mv :: [String] -> EmulatorState -> IO EmulatorState 
mv [] eState = do 
    putStrLn ("mv: too few arguments: ")
    return eState 
mv [oneArg] eState = do 
    putStrLn ("mv: too few arguments: " ++ oneArg)
    return eState 
mv [old, new] eState = do 
    let (WorkingDirectory currPath) = workingDir eState
    let oldPath = currPath </> old 
    let newPath = currPath </> new
    isEntry <- doesPathExist oldPath 
    if isEntry then do 
        _ <- renamePath oldPath newPath
        return eState
    else do 
        putStrLn ("mv: file does not exist: " ++ old)
        return eState
mv _ eState = do 
    putStrLn ("mv: too many arguments: " )
    return eState

history :: EmulatorState -> IO EmulatorState
history eState = do 
    let recentCommands = memory eState
    maybeOption <- historyPrompt recentCommands
    case maybeOption of 
        -- User just hit ENTER
        Nothing -> return eState 
        -- User typed something 
        Just strOption -> 
            case readMaybe strOption :: Maybe Int of
                Nothing -> do
                    putStrLn ("history: a valid option was not provided: " ++ strOption)
                    return eState
                Just index ->
                    -- make sure index is within bounds
                    -- if index >= 0 && index < length recentCommands
                    --     then do 
                    --         let cmd = recentCommands !! index 
                    --         handleCommand (words cmd) eState
                    --     else do 
                    --         putStrLn ("history: chosen option out of bounds: " ++ (show index))
                    --         return eState
                    if index >= 0 && index < length recentCommands 
                        then do 
                            let cmd = recentCommands !! index 
                            -- use editable prompt function from Terminal
                            editedCmd <- terminalEditablePrompt eState cmd
                            handleCommand (words editedCmd) eState
                        else do 
                            putStrLn ("history: chosen option out of bounds: " ++ (show index))
                            return eState

historyPrompt :: [Command] -> IO (Maybe String) 
historyPrompt [] = return Nothing
historyPrompt mem = do 
    mapM_ (\(command, i) -> putStrLn (command ++ " (" ++ (show i) ++ ")")) (zip mem [0 ..])
    putStr "Choose a past command or ENTER: "
    hFlush stdout
    option <- getLine
    case option of 
        "" -> return Nothing 
        _ -> return (Just option) 


-- terminal functions 
terminalEditablePrompt :: EmulatorState -> String -> IO Command 
terminalEditablePrompt eState cmd = do 
    let (WorkingDirectory currPath) = workingDir eState
    let currentDirName = takeBaseName currPath
    putStr ("anbu@emulator " ++ currentDirName ++ " ⋊> ")
    hFlush stdout
    command <- getLineWithCmd cmd
    return command 


-- custom getLine, lets the user edit initial string
getLineWithCmd :: String -> IO String
getLineWithCmd initialStr = do
    -- turn off standard terminal behaviors
    hSetBuffering stdin NoBuffering
    hSetEcho stdin False
    
    -- print the pre-filled command
    putStr initialStr
    hFlush stdout
    
    -- enter the custom typing loop
    finalStr <- typingLoop initialStr
    
    -- restore normal terminal behavior before returning
    hSetBuffering stdin LineBuffering
    hSetEcho stdin True
    return finalStr

typingLoop :: String -> IO String
typingLoop currentStr = do
    char <- getChar
    case char of
        -- enter key
        '\n' -> do
            putStrLn ""
            return currentStr
            
        -- backspace key
        '\DEL' -> handleBackspace currentStr
        '\b'   -> handleBackspace currentStr
        
        -- any character
        c -> do
            putStr [c]
            hFlush stdout
            typingLoop (currentStr ++ [c])

handleBackspace :: String -> IO String
handleBackspace currentStr = 
    if null currentStr
        then typingLoop currentStr
        else do
            -- backspace
            putStr "\b \b" 
            hFlush stdout
            -- Remove last char
            typingLoop (init currentStr) 

