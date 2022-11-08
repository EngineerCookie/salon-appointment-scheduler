#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
#Script: registering appointes for the salon database.
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SELECTION_QUERY () {
  #error fallback
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  echo "$($PSQL 'SELECT * FROM services')" | sed 's/|/) /'
  read SERVICE_ID_SELECTED
  #if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    SELECTION_QUERY "Please enter a valid number"
  #if not on the list
  else 
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
      then
      SELECTION_QUERY "I could not find that service. What would you like today?"
    else
      INFORMATION_INPUT
    fi
  fi
}

INFORMATION_INPUT () {
  #input phone
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  #check phone on customers table
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
    then
    #if phone not found, ask name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    #add new phone and name
    ADD_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    echo $ADD_CUSTOMER
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  #ask time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  #insert appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo $INSERT_APPOINTMENT
  #last echo
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}


SELECTION_QUERY