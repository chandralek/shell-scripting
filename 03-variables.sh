#!/bin/bash 

## Variable is a name which is associated to a set of data.
## Advantage: Change of data in one place will replicate in all the places where that variable is used.

## Declare a variable 
a=10      # Number 
b=xyz     # characters 
c=r200    # string 
d=20.90   # float 

# Observation: 
# Unlike other scripting languages Shell does not have data types by default.
# Everything is a string.

## Access Variables.

echo a = $a 
echo b = ${b}

# Observation 
  # Variable can be access just with $ preceding to the variable name, also variable can bounded in {}

## When to use {} 
echo $a100
echo ${a}100

# Also braces used for arrays. (Explore on your own)

## Requirement:  print welcome mesage with date 
DATE=2020-03-28
echo Welcome, Good Morning, Today date is $DATE 

# Problem on above message is , Printing same date all the days.

# Static data in variables cannot be a solution here or solution all the time.

# Dynamic Variables 
# 1. Command Substitution       syntax: a=$(command) or a=`command`
# 2. Arithematic Substitution   syntax: a=$((arthithematic expression))

DATE=$(date +%F)
echo Welcome, Good Morning, Today date is $DATE 

ADD=$((2+3+500))
echo $ADD 
## Due to limitations that arithematic expressions have we may not use it all the time.

# Problems 
# 1. Base 
#echo $((09-01))
# 2. Float
#echo $((99.99-9.09))

# Alternative to this is bc command.

# Environment variables

echo COURSE NAME = $COURSENAME


## Variable Name should have only the following
# 1. Character a-z, A-Z 
# 2. Numbers 0-9
# 3. Special Charactly : Only _ (underscore)

## No spcecial characters are allowed 
## Variable should not start with a number. 1var is invalid variable.
