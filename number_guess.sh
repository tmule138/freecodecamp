#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --tuples-only -c"

MAIN() {
echo -e "Enter your username:"

read USERNAME

## generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1))

## start count
count=0

## get user_id
USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")

## if user doesn't exist
if [[ -z $USER_ID ]]
then INSERT_NEW_USER=$($PSQL "insert into users(username) values('$USERNAME')")
  
  ## get new user ID
  USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
  
  ## welcome new user
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  
  ## inseert new record in games with user_id and start a new game
  NEW_GAME

else
## get game count and best game
USER_INFO=$($PSQL "select count(game_id) total_games, min(number_guess) best_game from games where user_id=$USER_ID")

## display user info
echo "$USER_INFO" | while read TOTAL_GAMES BAR BEST_GAME
do
  echo -e "Welcome back, $USERNAME! You have played $TOTAL_GAMES games, and your best game took $BEST_GAME guesses."
done
## create new game record with user id and start new game
NEW_GAME

fi
}

NEW_GAME() {
  INSERT_NEW_GAME=$($PSQL "insert into games(user_id,secret_number) values($USER_ID,$SECRET_NUMBER)")
  guessing_game "Guess the secret number between 1 and 1000:"
}

check_guess() {
## check if guess is an integer
if [[ $NUMBER_GUESS =~ ^[0-9]+$ ]]
then 
  ## check if guess is too high
  if [[ $NUMBER_GUESS > $SECRET_NUMBER ]]
  ## request another number guess when too high
  then guessing_game "It's lower than that, guess again:"
  else
    ## check if guess is too low
    if [[ $NUMBER_GUESS < $SECRET_NUMBER ]]
    ## request another guess when too low
    then guessing_game "It's higher than that, guess again:"
    else 
      ## guess == secret number
      if [[ $NUMBER_GUESS == $SECRET_NUMBER ]]
      then
        ## get current game id
        CURRENT_GAME_ID=$($PSQL "select max(game_id) from games where user_id=$USER_ID")
        ## update game details
        UPDATE_GAME=$($PSQL "update games set number_guess=$count where game_id=$CURRENT_GAME_ID")
        ## tell user they guessed correctly
        echo -e "You guessed it in $count tries. The secret number was $SECRET_NUMBER. Nice job!"
        ## finish running after correct guess
        exit
      fi
    fi
  fi
else
  ## solicit another guess when guess is not an integer
  guessing_game "That is not an integer, guess again:"  
fi
}

## guess a number
guessing_game() {
  if [[ $1 ]]
   then echo -e "$1"
  fi

read NUMBER_GUESS

(( count++ ))
check_guess
}

MAIN