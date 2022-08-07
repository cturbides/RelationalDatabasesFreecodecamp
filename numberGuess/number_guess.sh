#!/bin/bash

# Global variables
PSQL="psql -U freecodecamp -d number_guess -t --no-align -c"
COUNT=0

WELCOME_MESSAGE(){
  USER_DATA=$($PSQL "SELECT * FROM users WHERE user_id = $1;")
  IFS=" " read ID USERNAME GAMES_PLAYED BEST_GAME <<< "$(echo $USER_DATA | sed 's/|/ /g')"
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
}
ADD_GAME_PLAYED(){
  RESULT_GAME_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $1;")
  if [[ $RESULT_GAME_PLAYED != "UPDATE 1" ]]; then
    echo "Error -> Saving games played"
  fi
}

INSERTING_BEST_GAME(){
  RESULT_INSERTING_BEST_GAME=$($PSQL "UPDATE users SET best_game = $2 WHERE user_id = $1;")
  if [[ $RESULT_INSERTING_BEST_GAME != "UPDATE 1" ]]; then
    echo "Error -> Saving games played"
  fi
}
ADD_BEST_GAME(){
  ACTUAL_GAME=$2
  USER_ID=$1
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID;")
  if [[ $BEST_GAME = 0 ]]; then
    INSERTING_BEST_GAME $USER_ID $ACTUAL_GAME
  elif [[ $ACTUAL_GAME -lt $BEST_GAME ]]; then
    INSERTING_BEST_GAME $USER_ID $ACTUAL_GAME
  fi
}

GAME(){
  USER_ID=$1
  echo -e "\nGuess the secret number between 1 and 1000:"
  RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
  tries=1
  while :
  do
    read guess
    if [[ ! $guess =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
    else
      if [[ $guess != $RANDOM_NUMBER ]]; then
        tries=$(( $tries + 1 ))
        if [[ $guess > $RANDOM_NUMBER ]]; then
          echo -e "\nIt's lower than that, guess again:"
        else
          echo -e "\nIt's higher than that, guess again:"
        fi
      else
        break
      fi
    fi 
  done
  
  #Saving records on db
  ADD_GAME_PLAYED $USER_ID 
  ADD_BEST_GAME $USER_ID $tries
  echo -e "\nYou guessed it in $tries tries. The secret number was $RANDOM_NUMBER. Nice job!"
}

# Ask for username
echo "Enter your username:"
read USERNAME
# Check if username isn't null
if [[ -z $USERNAME ]]; then
  echo "You have to enter a username"
else
  # Query user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
  if [[ -z $USER_ID ]]; then
    USER_INSERTED=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME',0,0);")
    if [[ ! $USER_INSERTED = "INSERT 0 1" ]]; then
      echo "Error -> Inserting user"
    else
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
      echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
      GAME $USER_ID
    fi
  else
    WELCOME_MESSAGE $USER_ID
    GAME $USER_ID
  fi
fi