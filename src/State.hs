module State where 

data WorkingDirectory = WorkingDirectory FilePath 
    deriving (Show, Eq)
type Command = String

data EmulatorState = State {
    -- full path of working directory
    workingDir :: WorkingDirectory, 
    -- list of previous 10 commands
    memory :: [Command]
    } 
    deriving (Show, Eq)

memoryCapacity :: Int 
memoryCapacity = 10 

initialState :: EmulatorState
initialState = State {workingDir=WorkingDirectory "", memory=[]}