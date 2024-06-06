#!/bin/bash

# PSQL Query String
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Ensure correct number of arguments
if [[ $# != 1 ]]
then
  echo Please provide an element as an argument.
  exit 0
fi

# Search database for atomic number
# If element is an integer
if [[ $1 =~ ^[0-9]+$ ]]
then
  # Search by atomic number
  ATOMIC_NUMBER_SEARCH_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
  if [[ ! -z $ATOMIC_NUMBER_SEARCH_RESULT ]]
  then
    ATOMIC_NUMBER=$ATOMIC_NUMBER_SEARCH_RESULT
  fi
else
  # Search by symbol and name
  SYMBOL_SEARCH_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
  NAME_SEARCH_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
  if [[ ! -z $SYMBOL_SEARCH_RESULT ]]
  then
    ATOMIC_NUMBER=$SYMBOL_SEARCH_RESULT
  elif [[ ! -z $NAME_SEARCH_RESULT ]]
  then
    ATOMIC_NUMBER=$NAME_SEARCH_RESULT
  fi
fi

# If atomic number was not found
if [[ -z $ATOMIC_NUMBER ]]
then
  echo I could not find that element in the database.
  exit 0
fi

# Get required information from the database using atomic number
ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
ELEMENT_SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
ELEMENT_TYPE=$($PSQL "SELECT type FROM properties LEFT JOIN types USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER")
ELEMENT_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
ELEMENT_MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
ELEMENT_BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")

# Display info
echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $ELEMENT_TYPE, with a mass of $ELEMENT_MASS amu. \
$ELEMENT_NAME has a melting point of $ELEMENT_MELTING_POINT celsius and a boiling point of $ELEMENT_BOILING_POINT celsius."