Final Project: ⋊> Terminal Emulator in Haskell
=================================================

A terminal emulator written in Haskell that mimics the shell and allows a user to execute simple commands. 
The program consists of
- a terminal IO loop that displays the command prompt and gets the user input 
- functions that implement the backend logic for each possible command
- state handling for keeping track of the working directory and command history when commands are executed

The structure of the project is as follows:
1. src/Commands.hs: Handling emulator input
2. src/State.hs: Definitions for maintaining a global emulator state
3. src/Treminal.hs: Emulator loop
4. src/Tree.hs: Reusable backend logic for 'tree' command

The System.Directory library is used to make interfacing with the filesystem more convenient. 

### NOTE

The following commands are implemented in the program:
1. cd 
2. mv 
    (usage: call mv with two arguments of the same type, folder to folder or file to file)
    (eg: 'mv data.txt src/' will not work because data.txt is a file and src/ is a folder,
        but 'mv data.txt src/data.txt' will work!)
3. tree 
4. history
5. quit 
6. search (not implemented yet)

I wanted the search command to print a filtered tree displaying matches. I began to work on 
the logic to determine whether a tree node matched the search term. I started using parsec for that
and have a working parser that parses a string if it contains a specified substring. After spending
a bunch of time doing that I found out that I could use isInfixOf from Data.List. Therefore, I 
didn't have time to implement my filterTree function in Tree.hs which should return the filtered tree.
I did get to revisit the parsec library and play around with it, which was fun. I will definitely be 
implementing this feature before my presentation!

Running the Program
-------

In the root directory of the project, run the following:
    cabal build
    cabal run
