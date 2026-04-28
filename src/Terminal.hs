module Terminal where 

import System.Directory (getCurrentDirectory)
import System.FilePath (takeBaseName)
import System.IO (hFlush, stdout)
import System.Exit (exitSuccess)
import Commands
import State 

-- util
getWorkingDirectory :: IO WorkingDirectory 
getWorkingDirectory = do 
    dir <- getCurrentDirectory 
    return (WorkingDirectory dir)

-- terminal functions
terminalStart :: IO () 
terminalStart = do 
    putStrLn "Welcome to my terminal emulator! Enter help for more info\n"
    wDir <- getWorkingDirectory
    let startState = initialState{workingDir=wDir}
    terminalLoop startState

terminalLoop :: EmulatorState -> IO () 
terminalLoop eState = do 
    command <- terminalUntilQuit eState terminalPrompt
    let commandWords = parseCommand command
    newLocation <- handleCommand commandWords eState
    terminalLoop newLocation
    return ()

terminalUntilQuit :: EmulatorState -> (EmulatorState -> IO Command) -> IO Command
terminalUntilQuit eState prompt = do 
    command <- prompt eState 
    case command of 
        "quit" -> exitSuccess
        _ -> return command

terminalPrompt :: EmulatorState -> IO Command
terminalPrompt eState = do 
    let (WorkingDirectory currPath) = workingDir eState
    let currentDirName = takeBaseName currPath
    putStr ("anbu@emulator " ++ currentDirName ++ " ⋊> ")
    hFlush stdout
    command <- getLine
    return command 


