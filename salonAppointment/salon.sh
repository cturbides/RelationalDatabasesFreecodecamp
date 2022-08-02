#!/bin/bash

PSQL="psql -U freecodecamp -d salon --no-align -t -c"

MENU(){
  if [[ $1 ]]; then
    echo -e "$1\n"
  fi

  SERVICES_WE_OFFER=$($PSQL "SELECT * FROM services;")
  echo $SERVICES_WE_OFFER | sed -r 's/([0-9]+)\|/\n\1) /g' | while read ID NAME
  do
    if [[ -z $ID ]]; then
      echo "List of services we offer: "
    else
      echo $ID $NAME 
    fi
  done
  
  echo -e "\nPlease, select a service: "
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    MENU "Select a valid option!"
  else
    # query service_id
    SERVICE_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    # if not exist
    if [[ -z $SERVICE_SELECTED ]]; then
      MENU "Select a valid option!"
    else
      # echo -> phone number
      echo -e "\nPlease, enter your phone number: "
      # read phone number
      read CUSTOMER_PHONE
      
      # if customer not exist with phone number -> Create one
      CUSTOMER_BY_PHONE=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
      if [[ -z $CUSTOMER_BY_PHONE ]]; then
        # echo -> name
        echo -e "\nPlease, enter your name: "
        # read name
        read CUSTOMER_NAME

        RESULT_SAVING_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE');")
        if [[ ! $RESULT_SAVING_CUSTOMER = "INSERT 0 1" ]]; then
          MENU "Error while saving customer"
        fi
      fi  
      
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
      # echo -> appointment time
      echo -e "\nWhat hour you want to set appart?"
      # read appointment time
      read SERVICE_TIME
      # query appointment time
      RESULT_SAVING_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME');")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
      if [[ $RESULT_SAVING_APPOINTMENT = "INSERT 0 1" ]]; then
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi

  fi
  
}

MENU