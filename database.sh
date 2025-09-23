#!/bin/bash

show_usage() {
    echo "Usage: $0 {create_db|create_table|insert_data|select_data|delete_data} [arguments]"
    echo ""
    echo "Examples:"
    echo "  $0 create_db example_db"
    echo "  $0 create_table example_db persons id name height age"
    echo "  $0 insert_data example_db persons 0 Igor 180 36"
    echo "  $0 insert_data example_db persons 1 Pyotr 178 25"
    echo "  $0 select_data example_db persons"
    echo "  $0 delete_data example_db persons \"id=1\""
    echo ""
}

get_db_name()
{
    local db_name=$1
    echo "${db_name}.db"

}

check_db_exists()
{
   local db_file=$1
   if [[ ! -f $db_file ]]; then
   echo "Error: database $db_file does not exist"
   return 1
   fi
   return 0;
}

check_table_existance()
{
  local db_file=$1
  local table_name=$2
  if ! check_db_exists "$db_file"; then
    return 1
   fi
   local table_count=$(sqlite3 "$db_file" "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='$table_name';")
   if [[ $table_count -eq 0 ]]; then
   echo "Error:table $table_name does not exist"
   return 1
   fi
   return 0  

}

validate_field_count()
{
  local db_file=$1
  local table_name=$2
  local values_count=$3

  local actual_count=$(sqlite3 "$db_file" "PRAGMA table_info($table_name);" | wc -l) 
  if [[ $values_count -ne $actual_count ]]; then
        echo "Error: Expected $actual_count values, but got $values_count."
        return 1
    fi
    return 0

}

create_db() {
 local db_name=$1
local db_file=$(get_db_name "$db_name")

if [[ -f $db_file ]]; then
 echo "Database $db_file already exists"
 return 0
fi 

touch "$db_file"
if [[ -f $db_file ]]; then 
  echo "Database $db_file created successfully"
else  
  echo "Error failed to create database $db_file"
  return 1
fi  
}


create_table() {
   local db_name=$1
   local table_name=$2
   shift 2 
   local fields=($@)
   local db_file=$(get_db_name "$db_name")

   if ! check_db_exists "$db_file"; then
     return 1
    fi

    local sql="CREATE TABLE IF NOT EXISTS $table_name ("
    
    for ((i=0; i<${#fields[@]}; i++)); do
        if [[ $i -eq 0 ]]; then
            sql+="${fields[i]} INTEGER PRIMARY KEY"
        else
            sql+="${fields[i]} TEXT"
        fi
        
        if [[ $i -lt $((${#fields[@]} - 1)) ]]; then
            sql+=", "
        fi
    done
    
    sql+=");"

      if sqlite3 "$db_file" "$sql"; then
        echo "Table $table_name created successfully with fields ${fields[*]}"
       else
        echo "Error failed to created table $table_name"
        return 1
       fi

}  

insert_data() {
  local db_name=$1
  local table_name=$2
  shift 2
  local values=($@)
  local db_file=$(get_db_name "$db_name")

  if ! check_table_existance "$db_file" "$table_name"; then
      return 1
   fi   

  if ! validate_field_count "$db_file" "$table_name" "${#values[@]}"; then
    return 1
  fi  
  local sql="INSERT INTO $table_name VALUES("
  for ((i=0;i<${#values[@]};i++)); do
      sql+="'${values[i]}'"
      if [[ $i -lt $((${#values[@]}-1)) ]]; then
        sql+=", "
      fi
   done
   sql+=");"
 if sqlite3 "$db_file" "$sql"; then
   echo "Data inserted successfully into $table_name"
 else
    echo "Error failed to insert data into $table_name"
    return 1
  fi  

}


select_data() {
local db_name=$1
local table_name=$2
local where_clause=$3
local db_file=$(get_db_name "$db_name")

if ! check_table_existance "$db_file" "$table_name"; then
   return 1
fi

local sql="SELECT * FROM $table_name"

if [[ -n $where_clause ]]; then
   sql+=" WHERE $where_clause"
fi

sql+=";"

echo "Data from table $table_name"
echo ""

sqlite3 -header -column "$db_file" "$sql"

if [[ $? -ne 0 ]]; then
   echo "Error : Failed to select data from $table_name "
   return 1
fi   


}


delete_data() {
  local db_name=$1
  local table_name=$2
  local where_clause=$3
  local db_file=$(get_db_name "$db_name")

  if ! check_table_existance "$db_file" "$table_name"; then
     return 1
   fi

   if [[ -z $where_clause ]]; then
     echo "Error missing a where clause for the delete"
     return 1
   fi

   local sql="DELETE FROM $table_name WHERE $where_clause;"

   if sqlite3 "$db_file" "$sql"; then
     echo "Succssfully deleted from $table_name"
    else
      echo "Error: Failed to delete data from $table_name"    
       return 1
    fi   
}

list_tables() {
  local db_name=$1
  local db_file=$(get_db_name "$db_name")

  if ! check_db_exists "$db_file"; then
    return 1
  fi
  echo "Tables in database $db_file:"
  sqlite3 "$db_file" ".tables"  
}

main() {
   local command=$1
   shift

   case $command in
     "create_db")
            if [[ $# -ne 1 ]]; then 
               echo "Error created_db requires davase name argument"
               show_usage
               exit 1
            fi
            create_db "$1"
            ;;
     "create_table")
          if [[ $# -lt 3 ]]; then
              echo "Error create_table requires at leats 3 arguments"
              show_usage
              exit 1
           fi
           create_table "$@"
           ;;
    "insert_data")
         if [[ $# -lt 3 ]]; then 
          echo "Error:insert_data requieres 3 arguments"
          show_usage
          exit 1
         fi
         insert_data "$@"
         ;;
     "select_data")
          if [[ $# -lt 2 ]]; then 
          echo "Error:select_data requieres 2 arguments"
          show_usage
          exit 1
         fi
         select_data "$1" "$2" "$3"
         ;;   
    "delete_data")
          if [[ $# -ne 3 ]]; then 
          echo "Error:delete_data requieres 3 arguments"
          show_usage
          exit 1
         fi
         delete_data "$1" "$2" "$3"
         ;;  
     "list_tables")
          if [[ $# -ne 1 ]]; then
            echo "Error list_tables requeieres 1 argument"
            show_usage
            exit 1
           fi
           list_tables "$1"
           ;;
       "help"|"h"|"--help")
            show_usage
            ;;                 
       *)
         echo "Error:Unknown command $command"
         show_usage
         exit 1
         ;;
      esac    


}

main "$@"