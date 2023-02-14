#!/bin/bash
# Agrupamento de comandos na Bash
{ 
   i=1
   while read line; do 
     echo $i: $line
     i=$(($i+1)) 
   done 
} < $1
