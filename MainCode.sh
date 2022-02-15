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

function connectDB() {
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
              for ((i = 1; i <= $colsNum; i++)); do
                if [[ $i == 1 ]]; then
                  echo -e "ENTER PRIMARY KEY COLUMN NAME : \C"
                  read PKname
                  while [[ ! ($PKname =~ ^[a-zA-Z]*$) || $PKname = "" ]]; do
                    echo -e "invalid column name !!"
                    echo -e "ENTER PRIMARY KEY COLUMN NAME : \c"
                    read PKname
                  done
                else
                  echo -e "ENTER COLUMN NO.$i NAME : \C"
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

                if [[ $i -eq 1 ]]; then
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
          showList
          break
          ;;
        drop-table)
          clear
          break
          ;;
        insert-in-table)
          clear
          break
          ;;
        select-from-table)
          clear

          ;;
        delete-from-table)
          clear
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
  echo ENTER THE CHOICE YOU WANT
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
