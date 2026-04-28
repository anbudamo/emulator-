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

Testing
-------

You can test your answers using the provided test suite found in the `test`
directory.  Passing all tests of mandatory exercises will ensure a %100 score
(or > %100 if some bonus exercises are passed as well).  Any failing test for an
exercise shows that there is some problem in your code.

This test suite can be run automatically using `cabal` with the command

    cabal test
	
or using `stack` with the command

    stack test
	
While the formatting of their output differs somewhat (for example, `stack` uses
colors to differentiate successful versus failing properties), their results
will be the same.

You can pass some additional test options to selectively run only certain tests.
If you want to only run the tests for "regular" exercises, required to finish
the assignment %100, you can use one of the two commands:

    cabal test --test-options="--match Regular"
	
or

    stack test --test-arguments "--match Regular"

Inversely, if you only want to run the tests for "bonus" exercises, which can
earn extra credit, use one of the two commands

    cabal test --test-options="--match Bonus"
	
or

    stack test --test-arguments "--match Bonus"

### CAUTION

For your own good, do not modify anything in the `test` directory!
