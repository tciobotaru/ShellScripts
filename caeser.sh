#!/bin/bash
shift_amount=0
input_file=""
output_file=""

while getopts "s:i:o:" opt; do
   case $opt in
   s)
     shift_amount=$OPTARG
     ;;
   i)
     input_file=$OPTARG
     ;;
   o)
     output_file=$OPTARG   
     ;;
    \?)
    echo "Invalid option: -$OPTARG"
    exit 1
    ;; 
   esac 
 done 

 if [[ -z $input_file || -z $output_file ]]; then
 echo "Must provide file names"
 exit 1
 fi

if [[ ! -f $input_file ]]; then
 echo "Invalid input file: $input_file not found"
 exit 1;
fi

if [[ ! $shift_amount =~ ^-?[0-9]+$ ]]; then
 echo "error:Shift amount must be an integer" 
 exit 1
fi

shift_amount=$((shift_amount % 26))
if [[ $shift_amount -lt 0 ]]; then
   shift_amount=$((shift_amount+26))
fi

caeser()
{
 local char=$1
 local shift=$2

 if [[ $char =~ [A-Z] ]]; then
   local ascii=$(printf "%d" "'$char")
   local shifted=$(( (ascii - 65 + shift) % 26 + 65 ))
   printf "\\$(printf "%03o" $shifted)"
 elif [[ $char =~ [a-z] ]]; then
   local ascii=$(printf "%d" "'$char")
   local shifted=$(( (ascii - 97 + shift) % 26 + 97 ))
   printf "\\$(printf "%03o" $shifted)"
else
   printf "%s" $char
fi   




}

> $output_file


while IFS= read -r -n1 char; do
   if [[ -n $char ]]; then
     caeser $char $shift_amount >> $output_file
    else
    echo >> $output_file
    fi
done < $input_file

echo "Caesar chiper written in $output_file"

