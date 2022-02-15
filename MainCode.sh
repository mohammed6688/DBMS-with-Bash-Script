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
