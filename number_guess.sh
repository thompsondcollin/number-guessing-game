#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number (1-1000) that users have to guess
NUMBER=$(( $RANDOM % 1000 + 1 ))
echo $NUMBER
# Read username (at least 22 characters)
echo "Enter your username:"
read USER_NAME
# Check if past user
USER_INFO=$($PSQL "select username, games_played, best_game from games where username='$USER_NAME'")
if [[ ! -z $USER_INFO ]]
then
  # Display info
  echo $USER_INFO | while IFS=\| read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
else
  # Add user
  echo -e "Welcome, $USER_NAME! It looks like this is your first time here."
  NEW_USER=$($PSQL "insert into games(username, games_played, best_game) values('$USER_NAME', 0, 0)")
fi
# Read guess (in loop)
echo "Guess the secret number between 1 and 1000:" 
read NUMBER_GUESS
GAMES_COUNT=$($PSQL "select games_played from games where username='$USER_NAME'")
GUESS_COUNT=0
GAME() {
# Check if a number
if [[ $NUMBER_GUESS =~ ^[0-9]+$ ]]
then
  while [ $NUMBER_GUESS -ne $NUMBER ]
  do
    if [[ $NUMBER_GUESS =~ ^[0-9]+$ ]]
    then
      # Check if higher or lower
      if [[ $NUMBER_GUESS -lt $NUMBER ]]
      then
        ((GUESS_COUNT++))
        echo "It's higher than that, guess again:" 
        read NUMBER_GUESS
      else
        ((GUESS_COUNT++))
        echo "It's lower than that, guess again:" 
        read NUMBER_GUESS
      fi
    else
      echo "That is not an integer, guess again:" 
      read NUMBER_GUESS
    fi
  done
else
  echo "That is not an integer, guess again:" 
  read NUMBER_GUESS
  GAME
fi
}
GAME
# Correct guess
((GUESS_COUNT++))
((GAMES_COUNT++))
# Update info
UPDATE_GAMES=$($PSQL "update games set games_played=$GAMES_COUNT where username='$USER_NAME'")
USER_BEST=$($PSQL "select best_game from games where username='$USER_NAME'")
if [[ $GUESS_COUNT -lt $USER_BEST ]]
then
  UPDATE_GUESSES=$($PSQL "update games set best_game=$GUESS_COUNT where username='$USER_NAME'")
else
  if [[ $USER_BEST -eq o ]]
  then
    FIRST_GAME=$($PSQL "update games set best_game=$GUESS_COUNT where username='$USER_NAME'")
  fi
fi
echo -e "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"
