#!/bin/bash
#psql connection string
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\nWelcome to our salon!"
echo -e "\nWe offer the following services: \n"
AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

echo -e "\nPlease enter a service number: "
read SERVICE_ID_SELECTED

while [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
do
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e "\nPlease enter a valid number:"
  read SERVICE_ID_SELECTED
done

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

while [[ -z $SERVICE_NAME ]] 
do
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e "\nPlease enter a service number: "
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
done

echo -e "\nPlease enter your phone number: "
read CUSTOMER_PHONE
CUSTOMER_EXISTS_CHECK=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_EXISTS_CHECK ]] 
then
  echo -e "\nWe could not find you in our database. Please enter your name: "
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
fi

echo -e "\nPlease enter your desired appointment time: "
read SERVICE_TIME
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")

if [[ $INSERT_APPOINTMENT_RESULT = "INSERT 0 1" ]]
then
  echo "I have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
