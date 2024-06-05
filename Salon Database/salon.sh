#!/bin/bash

# Database Query String
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

# Title
echo -e "\n~~~~~ STELLAR STYLES SALON ~~~~~\n"

# Color
BLUE='\033[0;34m'
NC='\033[0m'

# Get services
SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

MAIN_MENU() {
  # Displays messages when getting sent back to the main menu
  if [[ $1 ]]
  then
    # Redirection message
    echo -e "\n$1"
  else
    # Welcome message
    echo -e "Welcome to Stellar Styles Salon! How may I help you?\n\nServices:"
  fi

  # Menu
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  # Formatting and Service Input
  echo
  echo -n -e "${BLUE}Input: ${NC}"
  read SERVICE_ID_SELECTED

  # If the service exists
  SELECTION_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SELECTION_RESULT ]]
  then
    MAIN_MENU "That option does not exist. Please try another option.\n\nServices:"
  else
    BOOK_APPOINTMENT $SERVICE_ID_SELECTED
  fi

  return
}

BOOK_APPOINTMENT() {
  # Get phone number
  echo -e "\nYou're going to need an appointment for that."
  echo "Just let me know what your phone number is so I can find you in the system ..."
  echo
  echo -n -e "${BLUE}Input: ${NC}"
  read CUSTOMER_PHONE

  # Check the database for the customer's id
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    # If not found, get name
    echo -e "\nI'm not seeing your number in the system."
    echo "Could I get a name for the appointment?"
    echo
    echo -n -e "${BLUE}Input: ${NC}"
    read CUSTOMER_NAME

    # Input customer into the database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

    # Check for success
    if [[ $INSERT_CUSTOMER_RESULT = "INSERT 0 1" ]]
    then
      echo -e "\nGot it."
    else
      echo -e "\nIt looks like there is an issue with the system."
      echo "Just let me pull out a piece of paper..."
    fi

  else
    echo -e "\nAlright, just let me pull up your details..."
  fi

  # Get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # Get service name from database
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # Get appointment time
  echo -e "Okay $CUSTOMER_NAME, what time would you like to have your $SERVICE?"
  echo
  echo -n -e "${BLUE}Input: ${NC}"
  read SERVICE_TIME

  # Input the appointment into the database
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Goodbye message
  echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  echo -e "See you then!\n"

  return
}

MAIN_MENU
