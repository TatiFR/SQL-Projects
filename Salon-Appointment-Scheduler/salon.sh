#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else 
    echo "Welcome to My Salon, how can I help you?"
  fi
  
  SERVICE_LIST=$($PSQL "select service_id, name from services")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED 
  

  case $SERVICE_ID_SELECTED in
    1) APPOINTMENT_MENU ;;
    2) APPOINTMENT_MENU ;;
    3) APPOINTMENT_MENU ;;
    4) APPOINTMENT_MENU ;;
    5) APPOINTMENT_MENU ;;
    6) APPOINTMENT_MENU ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;

  esac
}

APPOINTMENT_MENU() {
  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED") 
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nI don't have a record for that phone number, What's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME

  # insert message 
  INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  
  # send to main menu
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

}

MAIN_MENU
