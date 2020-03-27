#!/bin/bash 

## To print some message on the screen we choose printing commands.
# there are two commands which can print a mesage
# 1. echo 
# 2. printf 

# We choose to go with echo as it reduces the syntax problems unlike printf.

echo Hello World 

# Escape sequences.

## New line. (\n)

echo -e "Hello DevOps,\nBye"

# Observations: 
  # 1. When you use escape seq, Always use -e option
  # 2. When you use escape seq, Always provide input in quotes, Double is preferred 

## Tab Spaces (\t)

echo -e "One\t\t\t\tTwo"

## Color Code (\e)

#echo -e "\e[COL-CODEmMessage"

# Colors are two types 
## Color                ForegroundColor             BackgroundColor 
# Red                         31                          41
# Green                       32                          42
# Yello                       33                          43
# Blue                        34                          44
# Magenta                     35                          45
# Cyan                        36                          46

echo -e "\e[31mHello World in Red Color"
