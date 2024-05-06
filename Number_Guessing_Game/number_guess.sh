#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
PSQL2="psql --username=freecodecamp --dbname=number_guess -t -c"

# Library functions
READ_UNTIL_INT() {
  read READ_UNTIL_INT_ZZ
  until [[ $READ_UNTIL_INT_ZZ =~ ^[0-9]+$ ]]
  do
    echo $1
    read READ_UNTIL_INT_ZZ
  done
  echo $READ_UNTIL_INT_ZZ
}


TOKEN_IN_ARR() {
  # echo Is it in $2
  for ZZEL in $2
  do
    if [[ $ZZEL == $1 ]]
    then
      echo true
      return
    fi
  done
  echo false
}

GEN_NUMBER() {
  echo $((1+$RANDOM%1000))
}

# Project code

GET_USER() {
  # Prompt username
  echo Enter your username:
  read USERNAME
  # If username invalid
  if [[ ${#USERNAME} -gt 22 ]]
  then
    GET_USER
    return
  fi
  USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")
  # echo Res:"'$USERNAME_RESULT'"
  if [[ -z $USERNAME_RESULT ]]
  then
    # If not exists, add to db
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    A=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0);")
  else
    # If username exists, print data
    USER_DATA=$($PSQL2 "SELECT user_id, games_played, fewest_guesses FROM users WHERE username='$USERNAME';")
    # echo Data: "'$USER_DATA'"
    echo "$USER_DATA" | while read USER_ID PIPE GAMES_PLAYED PIPE FEWEST
    do
      # A=1
      # echo "ID: $USER_ID; Games: $GAMES_PLAYED"
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $FEWEST guesses."
    done
  fi
}

PLAY() {
  NUM=$(GEN_NUMBER)
  # echo "Number: '$NUM'"
  NUM_GUESSES=0
  GUESS=0
  echo Guess the secret number between 1 and 1000:
  until [[ $GUESS -eq $NUM ]]
  do
    # Get guess until user enters an int
    read GUESS
    until [[ $GUESS =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read GUESS
    done
    # echo Guess: "'$GUESS'"
    NUM_GUESSES=$(($NUM_GUESSES + 1))
    # While guess is wrong
    if [[ $GUESS -lt $NUM ]]
    then
      echo "It's higher than that, guess again:"
    fi
    if [[ $GUESS -gt $NUM ]]
    then
      echo "It's lower than that, guess again:"
    fi
  done
  # When guess is correct
  echo "You guessed it in $NUM_GUESSES tries. The secret number was $NUM. Nice job!"
}

LOG_GAME_DATA() {
  USER_DATA=$($PSQL2 "SELECT user_id, games_played, fewest_guesses FROM users WHERE username='$USERNAME';")
  # echo Data: "'$USER_DATA'"
  echo "$USER_DATA" | while read USER_ID PIPE GAMES_PLAYED PIPE FEWEST
  do
    # A=1
    # echo "ID: $USER_ID; Games: $GAMES_PLAYED"
    GAMES_PLAYED=$(($GAMES_PLAYED+1))
    if [[ -z $FEWEST ]]
    then  
      FEWEST=$NUM_GUESSES
    else
      FEWEST=$((FEWEST<NUM_GUESSES ? FEWEST : NUM_GUESSES))
    fi
    # echo gp: "'$GAMES_PLAYED'"
    # echo fg: "'$FEWEST'"
    A=$($PSQL "UPDATE users SET games_played='$GAMES_PLAYED' WHERE username='$USERNAME';")
    A=$($PSQL "UPDATE users SET fewest_guesses='$FEWEST' WHERE username='$USERNAME';")
  done  
}

GET_USER
PLAY
LOG_GAME_DATA
