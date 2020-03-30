#!/bin/bash

# Every command sends a status back after its execution and that status is called exit status

## Exit states are 0-255

# 0 - Success 
# 1-255 - Not Success / Partial Success / Partial Failure 

## System by default stores the exit status of last command in ? variable 

exit 100

## Values from 126-255 are used by system, Hence it is not recomended to use those values 

## Note: exit command will terminate the script if it is been encountered. Meaning the next commands are not going to be executed any more.

## Student Exploring : 
  # 1. System states 126 - 255 
  # 2. Print STDERR
  # 3. Explore left over special variables.
