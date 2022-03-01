#!/bin/bash

mkdir DB 2>>/dev/null
cd DB
clear
PS3="enter value >>>"

function listDB() {
  x=$(ls | wc -l)
  if [ $x -eq 0 ]; then
    echo -e "THERE IS NO DATABASE FOUND\n"
  else
    echo $x DATABASES FOUND :
    ls
    echo -e "\n"
  fi
}

function listTable() {
  x=$(ls | wc -l)
  if [ $x -eq 0 ]; then
    echo -e "THERE IS NO TABLES FOUND\n"
  else
    echo There is $x TABLES FOUND in Database :
    ls
    echo -e "\n"
  fi
}

function deleteTable() {
  echo -e "WRITE THE TABLE YOU WANT TO DROP \n"
  read tablename
  if [ -f $tablename ]; then
    rm -r $tablename
    rm -r .$tablename
    echo "THE TABLE DELETED SUCCESSFULLY"
  else
    echo $tablename IS NO found
  fi
}

function insertInTable() {
  listTable
  echo ENTER THE TABLE NAME YOU WANT TO INSERT INTO
  read tableName
  if ! [ -f $tableName ]; then
    echo $tableName IS NOT EXIST
  else
    colsNum=$(awk 'END{print NR}' .$tableName)
    sep="|"
    rSep="\n"
    row=""
    for ((i = 2; i <= $colsNum; i++)); do
      # trace on each record in metadata hidden file
      colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
      colType=$(awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
      # get record values from user
      echo -e "$colName ($colType) = \c"
      read data
      # is it a primary key ?
      # colKey == "PK"
      if [[ $i -eq 2 ]]; then
        while [[ true ]]; do
          # if it is a primary key so
          # check if it is available
          if [[ $colType == "int" ]]; then
            while [[ ! ($data =~ ^[0-9]*$) && $data != "" ]]; do
              echo -e "PRIMARY KEY IS INVALID"
              echo -e "$colName ($colType) = \c"
              read data
            done
          fi
          if [[ $colType == "varchar" ]]; then
            while [[ ! ($data =~ ^[a-zA-Z]*$) && $data != "" ]]; do
              echo -e "PRIMARY KEY IS INVALID"
              echo -e "$colName ($colType) = \c"
              read data
            done
          fi
          if [ "$data" = "$(awk -F "|" '{ print $1 }' $tableName | grep "^$data$")" ]; then
            echo -e "PRIMARY KEY IS ALREADY EXIST \n"
            echo -e "$colName ($colType) = \c"
            read data
          else
            break
          fi
        done
      fi
      # Validate datatype
      # is it an integer ?
      if [[ $i -ne 2 ]]; then
        if [[ $colType == "int" ]]; then
          while ! [[ $data =~ ^[0-9]*$ ]]; do
            echo -e "invalid DataType !!"
            echo -e "$colName ($colType) = \c"
            read data
          done
        fi
        # is it a varchar ?
        if [[ $colType == "varchar" ]]; then
          while ! [[ $data =~ ^[a-zA-Z!@$%*_+-]*$ ]]; do
            echo -e "invalid DataType !!"
            echo -e "$colName ($colType) = \c"
            read data
          done
        fi
      fi
      #Set value in record
      if [[ $i == $colsNum ]]; then
        row=$row$data$rSep
      else
        row=$row$data$sep
      fi
      echo -e $row"\c" >>$tableName
#      clear
      row=""
    done
    if [[ $? == 0 ]]; then
      echo -e "\nData Inserted Successfully\n"
    else
      echo -e "\nError Inserting Data into Table $tableName\n"
    fi
  fi
}

function deleteFromTable() {
  listTable
  echo ENTER THE TABLE NAME YOU WANT TO DELETE FROM
  read tableName
  if ! [ -f $tableName ]; then
    echo $tableName IS NOT EXIST
  else
    echo -e "Enter Condition Value: \c"
    read value
    # check if your Value exist
    result=$(awk 'BEGIN{FS="|"}{if ( $1 == "'$value'" ) print $1 }' $tableName 2>>/dev/null)
    # echo $result
    if [[ $result == "" ]]; then
      # it dosn't exist
      echo "Value Not Found"
    else
      # get the line number of the value to delete it
      NR=$(awk 'BEGIN{FS="|"}{if ( $1 == "'$value'" ) print NR}' $tableName 2>>/dev/null)
      # edit the table and delete the record
      sed -i ''$NR'd' $tableName 2>>/dev/null
      # clear
      if [[ $? == 0 ]]; then
        # The Row Deleted Successfully
        echo -e "\nRow Deleted Successfully\n"
      else
        echo -e "\nRow didn't delete\n"
      fi
    fi
  fi
}

function selectTable() {
  while [ 1 ]; do
    echo CHOOSE FROM SELECT MENU
    select choice in "select-all" "select-specific-record" "back-to-db-menu" "back-to-table-menu" "exit"; do
      case $choice in
      select-all)
        listTable
        echo -e "ENTER TABLE NAME YOU WANT TO SELECT : \c"
        read tableName
        if ! [[ -f $tableName ]]; then
          # it dosn't exist
          clear
          echo -e "Table $tableName isn't existed\n"
          break
        fi
        clear
        # display each column in table
        column -t -s '|' $tableName 2>>/dev/null
        if [[ $? != 0 ]]; then
          echo "Error Displaying Table $tableName"
        fi
        echo -e "\n"
        break
        ;;
      select-specific-record)
        listTable
        echo -e "Enter Table Name: \c"
        read tableName
        if ! [[ -f $tableName ]]; then
          # it dosn't exist
          clear
          echo -e "Table $tableName isn't existed\n"
          # back to the menu 2
          break
        fi
        echo -e "Enter Condition Value: \c"
        read value
        # check if your Value exist
        result=$(awk 'BEGIN{FS="|"}{if ( $1 == "'$value'" ) print $1 }' $tableName 2>>/dev/null)
        # echo $result
        if [[ $result == "" ]]; then
          # it dosn't exist
          clear
          echo -e "Value Not Found\n"
        else
          # it exists so
          # get the line number of the value to select it
          NR=$(awk 'BEGIN{FS="|"}{if ( $1 == "'$value'" ) print NR}' $tableName 2>>/dev/null)
          clear
          echo $(awk 'BEGIN{FS="|";}{if ( NR == 1 ) print $0 }' $tableName 2>>/dev/null)
          echo $(awk 'BEGIN{FS="|";}{if ( NR == '$NR' ) print $0 }' $tableName 2>>/dev/null)
          if [[ $? != 0 ]]; then
            echo -e "\nError selecting Data from Table $tableName\n"
          fi
          echo -e "\n"
        fi
        break
        ;;
      back-to-db-menu)
        clear
        cd ..
        break 2
        ;;
      back-to-table-menu)
        clear
        break 2
        ;;
      exit)
        clear
        exit
        ;;
      *)
        clear
        echo INVALID CHOICE
        break
        ;;
      esac
    done
  done
}

function connectDB() {
  listDB
  echo ENTER THE DB YOU WANT TO CONNECT ON:
  read DBname
  if [ -d $DBname ]; then
    cd $DBname
    echo CONNECTED SUCCESSFULLY
    while [ 1 ]; do
      select choice in "create-table" "list-table" "drop-table" "insert-in-table" "select-from-table" "delete-from-table" "back-to-db-menu" "exit"; do
        case $choice in
        create-table)
          clear
          echo ENTER TABLE NAME
          read tablename
          if ! [[ $tablename =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
            echo INVAILD TABLE NAME
          else
            if [ -f $tablename ]; then
              echo -e $tablename " IS ALREADY EXIST \n"
            else
              echo -e "ENTER NUMBER OF COLUMNS : \c"
              read colsNum
              while [[ ! ($colsNum =~ ^[0-9]*$) || $colsNum = "" ]]; do
                echo -e "INVALID NUMBER"
                echo -e "ENTER NUMBER OF COLUMNS : \c"
                read colsNum
              done
              sep="|"
              rSep="\n"
              metaData="Field"$sep"Type"$sep"key"
              for ((i = 0; i < $colsNum; i++)); do
                if [[ $i == 0 ]]; then
                  echo -e "ENTER PRIMARY KEY COLUMN NAME : \c"
                  read colName
                  while [[ ! ($colName =~ ^[a-zA-Z]*$) || $colName = "" ]]; do
                    echo -e "invalid column name !!"
                    echo -e "ENTER PRIMARY KEY COLUMN NAME : \c"
                    read colName
                  done
                else
                  echo -e "ENTER COLUMN NO.$i NAME : \c"
                  read colName
                  while [[ ! ($colName =~ ^[a-zA-Z]*$) || $colName = "" ]]; do
                    echo -e "invalid column name !!"
                    echo -e "Name of Column No.$i: \c"
                    read colName
                  done
                fi
                echo -e "Type of Column $colName: "
                select var in "int" "varchar"; do
                  case $var in
                  int)
                    colType="int"
                    break
                    ;;
                  varchar)
                    colType="varchar"
                    break
                    ;;
                  *)
                    echo INVALED CHOICE
                    ;;
                  esac
                done

                if [[ $i -eq 0 ]]; then
                  metaData+=$rSep$colName$sep$colType$sep"PK"
                else
                  metaData+=$rSep$colName$sep$colType$sep""
                fi
                # columns names
                if [[ $i == $colsNum ]]; then
                  temp=$temp$colName
                else
                  # when count < colsNum
                  temp=$temp$colName$sep
                fi
              done
              touch .$tablename
              echo -e $metaData >>.$tablename
              touch $tablename
              echo -e $temp >>$tablename
              clear
              if [[ $? == 0 ]]; then
                echo -e "Table Created Successfully\n"
              else
                echo -e "Error Creating Table $tablename\n"
              fi
            fi
          fi
          break
          ;;
        list-table)
          clear
          listTable
          break
          ;;
        drop-table)
          clear
          deleteTable
          break
          ;;
        insert-in-table)
          clear
          insertInTable
          break
          ;;
        select-from-table)
          clear
          selectTable
          break
          ;;
        delete-from-table)
          clear
          deleteFromTable
          break
          ;;
        back-to-db-menu)
          clear
          cd ..
          break 2
          ;;
        exit)
          clear
          exit
          ;;
        *)
          clear
          echo YOU ENTERED WRONG NUMBER
          break
          ;;
        esac
      done
    done
  else
    echo -e $DBname " IS NOT FOUND \n"
  fi
}

while [ 1 ]; do
  echo $(tput bold)"ENTER THE CHOICE YOU WANT"$(tput sgr0)
  select choice in "Create-Database" "List-Tables" "Connect-To-Databases" "Drop-Database" "EXIT"; do
    case $choice in
    Create-Database)
      echo "ENTER YOUR Database NAME"
      read DBname
      #      check if db name is valid
      if ! [[ $DBname =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
        clear
        echo -e "ENTER VALID DATABASE NAME \n"
      else
        #        check if the database exist
        if [ -d $DBname ]; then
          clear
          echo -e $DBname "DATABASE ALREDY EXISTES \n"
          break
        else
          clear
          mkdir $DBname
          echo -e $DBname "CREATED SUCCESSFULLY \n"
          break
        fi
      fi
      ;;
    List-Tables)
      clear
      listDB
      break
      ;;
    Connect-To-Databases)
      clear
      connectDB
      break
      ;;
    Drop-Database)
      echo -e "ENTER THE NAME OF DB YOU WANT TO DROP"
      read DBname
      if [ -d $DBname ]; then
        clear
        rm -r $DBname
        echo -e $DBname "DROP SUCCESSFULLY \n"
        break
      else
        clear
        echo -e $DBname" IS NOT FOUND \n"
        break
      fi
      ;;
    EXIT)
      break 2
      ;;
    *)
      clear
      echo -e "ENTER VALID NUMBER \n"
      break
      ;;
    esac
  done
done

