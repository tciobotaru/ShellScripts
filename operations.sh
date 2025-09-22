#!/bin/bash
operation=""
numbers=()
debug_mode=false
user=$(whoami)
script_name=$(basename "$0")

while [[ $# -gt 0 ]]; do
  case $1 in
     -o)
       operation="$2"
       shift 2
       ;;
     -n)  
       shift 
       while [[ $# -gt 0 ]] && [[ $1 != -* ]]; do
            numbers+=("$1")
            shift
       done
       ;;
     -d) 
        debug_mode=true
        shift
        ;;
      *)
        echo "Unknown option $1"
        exit 1
        ;;
      esac
done                 

if [[ -z "$operation" ]] || [[ ${#numbers[@]} -lt 2 ]]; then 
    echo "Error:Missing requiered arguments"
    exit 1
fi

if [[ ! $operation =~ ^[+-\*%]$ ]]; then
  echo "Error:Invalid operation $operation "
  exit 1
fi

for num in "${numbers[@]}"; do
  if [[ ! $num =~ ^[0-9]+$ ]]; then
  echo "Error $num is not a valid number"
  exit 1
  fi
done  

if [[ $debug_mode == true ]]; then
  echo "User: $user"
  echo "Script: $script_name"
  echo "Operation: $operation"
  echo "Numbers: ${numbers[@]}"
fi


result=${numbers[0]}

for (( i=1;i<${#numbers[@]}; i++));  do
  case $operation in
  +)
    result=$((result+numbers[i]))
    ;;
  -)
    result=$((result-numbers[i]))
    ;;
  \*)
    result=$((result*numbers[i]))
    ;;
  %) 
    if [[ ${numbers[i]} -eq 0 ]]; then
    echo "Division by 0 is impossible"
    exit 1;
    fi
    result=$((result % numbers[i]))
    ;;
   esac
 done

 echo "Result : $result "   
