#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

IS_INT() {
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    echo false
  fi
  echo true
}


TOKEN_IN_ARR() {
  # echo Is it in $2
  for EL in $2
  do
    if [[ $EL == $1 ]]
    then
      echo true
      return
    fi
  done
  echo false
}


NOT_FOUND() {
  echo I could not find that element in the database.
  # exit
}


GET_ATOMIC_NUMBER() {
  if $(IS_INT $1)
  then
    ATOMIC_NUMS=$($PSQL "SELECT atomic_number FROM elements;")
    # echo --$ATOMIC_NUMS--
    # If entered int is in the db
    # echo $(TOKEN_IN_ARR $1 "${ATOMIC_NUMS[@]}")
    if $(TOKEN_IN_ARR $1 "${ATOMIC_NUMS[@]}")
    then
      # Return the atomic number
      # echo Found element num $1
      ATOMIC_NUM=$1
    else
      # NOT_FOUND
      echo I could not find that element in the database.
      return
    fi
  else
    # If not an int
    # echo Not int
    SYMBOLS=$($PSQL "SELECT symbol FROM elements;")
    NAMES=$($PSQL "SELECT name FROM elements;")
    # If entry is a symbol in the db
    if $(TOKEN_IN_ARR $1 "${SYMBOLS[@]}")
    then
      ATOMIC_NUM=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1';")
    elif $(TOKEN_IN_ARR $1 "${NAMES[@]}")
    then
      ATOMIC_NUM=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1';")
    else
      ATOMIC_NUM=0
    fi
  fi
  echo $ATOMIC_NUM
}


# If no CL args, print error
if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
  exit
fi


PRINT_DATA() {
  ELEMS_DATA=$($PSQL "SELECT symbol, name FROM elements WHERE atomic_number='$1'")
  IFS='|' read -ra SYMBOL_NAME <<< "$ELEMS_DATA"
  # for i in "${SYMBOL_NAME[@]}";
  # do
  #   echo $i
  # done
  PROPS_DATA=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number='$1'")
  IFS='|' read -ra MASS_MELT_BOIL_TYPEID <<< "$PROPS_DATA"
  # for i in "${MASS_MELT_BOIL_TYPEID[@]}";
  # do
  #   echo $i
  # done
  TYPE=$($PSQL "SELECT type FROM types WHERE type_id='${MASS_MELT_BOIL_TYPEID[3]}'")
  echo "The element with atomic number $1 is "${SYMBOL_NAME[1]}" ("${SYMBOL_NAME[0]}"). It's a "$TYPE", with a mass of "${MASS_MELT_BOIL_TYPEID[0]}" amu. "${SYMBOL_NAME[1]}" has a melting point of "${MASS_MELT_BOIL_TYPEID[1]}" celsius and a boiling point of "${MASS_MELT_BOIL_TYPEID[2]}" celsius."
}

ATOMIC_NUMBER=$(GET_ATOMIC_NUMBER $1)
if [[ $ATOMIC_NUMBER = 0 ]]
then
  NOT_FOUND
  exit
fi
# echo Num: $ATOMIC_NUMBER
PRINT_DATA $ATOMIC_NUMBER
