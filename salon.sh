#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"

DISPLAY_SERVICES() {
 if [[ $1 ]]
 then
   echo -e "\n$1"
 fi 

 # get services
 SERVICES=$($PSQL "select service_id, name from services order by service_id")

 # display services
 echo "$SERVICES" | while read SERVICE_ID BAR NAME
 do
   echo "$SERVICE_ID) $NAME"
 done
}

APPOINTMENT_MENU() {
  
DISPLAY_SERVICES "Welcome to My Salon, how can I help you?"

# select service
  read SERVICE_ID_SELECTED
    # check if service is valid
    VALID_SERVICE=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
    
    # if service is invalid
    if [[ -z $VALID_SERVICE ]]
    then
    # send to DISPLAY SERVICES
    DISPLAY_SERVICES "I could not find that service. What would you like today?"

    else

    # get customer info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
      
      #if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then 
        # get new customer name
        echo -e "\nI don't have a record for that phone number. What's your name?"
        read CUSTOMER_NAME

        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      fi
    # get service name
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    
    # get appointment time
    echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # get appointment info
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

    # create appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

    # confirm appointment
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

    fi
}

APPOINTMENT_MENU

