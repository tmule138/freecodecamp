#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"


DISPLAY_ELEMENT_INFO() {
  echo $ELEMENT_DATA | while read ATOMIC_NUMBER BAR NAME BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT
  do echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
}

if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
  exit
  # if input is not a number
else if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    # find element data assuming symbol
    ELEMENT_DATA=$($PSQL "select e.atomic_number,e.name,e.symbol,t.type,p.atomic_mass,p.melting_point_celsius,p.boiling_point_celsius from elements e inner join properties p on e.atomic_number=p.atomic_number inner join types t on p.type_id=t.type_id  where e.symbol='$1'")
      # if input is not a symbol
      if [[ -z $ELEMENT_DATA ]]
      then 
        # find element data by name
        ELEMENT_DATA=$($PSQL "select e.atomic_number,e.name,e.symbol,t.type,p.atomic_mass,p.melting_point_celsius,p.boiling_point_celsius from elements e inner join properties p on e.atomic_number=p.atomic_number inner join types t on p.type_id=t.type_id  where e.name='$1'")
          # if input is not a name
          if [[ -z $ELEMENT_DATA ]]
          then
            echo -e "I could not find that element in the database."
          else
          # display element info
          DISPLAY_ELEMENT_INFO
          fi
      else
      # display element info
      DISPLAY_ELEMENT_INFO
      fi
  else  
  # find element data using atomic number
  ELEMENT_DATA=$($PSQL "select e.atomic_number,e.name,e.symbol,t.type,p.atomic_mass,p.melting_point_celsius,p.boiling_point_celsius from elements e inner join properties p on e.atomic_number=p.atomic_number inner join types t on p.type_id=t.type_id  where e.atomic_number='$1'")
    # if input is not an atomic number
    if [[ -z $ELEMENT_DATA ]]
    then
    echo -e "I could not find that element in the database."
    else
    # display element info
    DISPLAY_ELEMENT_INFO
    fi
  fi
fi



