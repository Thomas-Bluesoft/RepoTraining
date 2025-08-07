#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# show services
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

DISPLAY_SERVICES() {
  
#list of services
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
 echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

MAIN_MENU() {

DISPLAY_SERVICES

  #read services
   read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. try again?"
  else
    ASK_FOR_PHONE
  fi
}

 ASK_FOR_PHONE() {
  echo -e "\nWhat's your phone number ?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #if unknown
  if [[ -z $CUSTOMER_NAME ]]
  then 
    echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
     $PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  ASK_FOR_TIME
 }

 ASK_FOR_TIME() {
     echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME ?"
      read SERVICE_TIME  

         $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

         SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *//g')

        echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."

 }

 MAIN_MENU