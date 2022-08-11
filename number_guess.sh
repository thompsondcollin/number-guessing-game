#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number (1-1000) that users have to guess
NUMBER=$(( $RANDOM % 1000 + 1 ))
echo $NUMBER
# Read username (at least 22 characters)
read -p "Enter your username:" USER_NAME
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
  NEW_USER=$($PSQL "insert into games(username, games_played, best_game) values('$USER_NAME', 0, 1000)")
fi
# Read guess (in loop)
read -p "Guess the secret number between 1 and 1000:" NUMBER_GUESS
GAMES_COUNT=$($PSQL "select games_played from games where username='$USER_NAME'")
GUESS_COUNT=0
while [ $NUMBER_GUESS -ne $NUMBER ]
do
  # Check if a number
  if [[ $NUMBER_GUESS =~ ^[0-9]+$ ]]
  then
    # Check if higher or lower
    if [[ $NUMBER_GUESS -gt $NUMBER ]]
    then
      ((GUESS_COUNT++))
      read -p "It's lower than that, guess again:" NUMBER_GUESS
    else
      ((GUESS_COUNT++))
      read -p "It's higher than that, guess again:" NUMBER_GUESS
    fi
  else
    read -p "That is not an integer, guess again:" NUMBER_GUESS
  fi
done
# Correct guess
((GUESS_COUNT++))
((GAMES_COUNT++))
# Update info
$($PSQL "insert into games(games_played) values($GAMES_COUNT) where username='$USER_NAME'")
if [[ $GUESS_COUNT < $BEST_GAME ]]
then
  $($PSQL "insert into games(best_game) values($GUESS_COUNT) where username='$USER_NAME'")
fi
echo -e "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"
