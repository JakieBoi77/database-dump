#!/bin/bash

#PSQL Query String
PSQL="psql --username=freecodecamp --dbname=users -t --no-align -c"

# Get username from the user
echo -n "Enter your username: "
read USERNAME

# Search for user_id using the user's username
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# If user is not found
if [[ -z $USER_ID ]]
then
  # Welcome the new user and add them to the database
  echo Welcome, $USERNAME! It looks like this is your first time here.
  INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  if [[ $INSERT_RESULT != "INSERT 0 1" ]]
  then
    echo There appears to be an issue with our database...
  fi
  
  # Update info
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
  
else
  # Get users info and welcome them back
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

# Generate random number and initialze guesses
RANDOM_NUMBER=$((1 + $RANDOM % 1000))
NUMBER_OF_GUESSES=0

# Start the game
while [[ $GUESS != $RANDOM_NUMBER ]]
do
  if [[ $NUMBER_OF_GUESSES = 0 ]]
  then
    # Print on the first guess
    echo -n "Guess the secret number between 1 and 1000: "
  elif [[ $GUESS < $RANDOM_NUMBER ]]
  then
    # Print when the guess is too low
    echo -n "It's higher than that, guess again: "
  elif [[ $GUESS > $RANDOM_NUMBER ]]
  then
    # Print when the guess is too high
    echo -n "It's lower than that, guess again: "
  fi
  
  # Read the guess
  read GUESS

  # Ensure that the guess is an integer
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo -n "That is not an integer, guess again: "
    read GUESS
  done

  # Increment number of guesses
  (( NUMBER_OF_GUESSES++ ))
done

# Print results
echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!

# Update the user's games played
(( GAMES_PLAYED++ ))
INSERT_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID")
if [[ $INSERT_RESULT != "UPDATE 1" ]]
then
  echo Error updating games played.
fi

# Update the user's best game
if [[ $NUMBER_OF_GUESSES < $BEST_GAME || -z $BEST_GAME ]]
then
  INSERT_RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE user_id = $USER_ID")
  if [[ $INSERT_RESULT != "UPDATE 1" ]]
  then
    echo Error updating best game.
  fi
fi