#!/bin/bash
PSQL="psql -U freecodecamp -d periodic_table --no-align --tuples-only -c"
NOT_FOUND="I could not find that element in the database."

INFO() {
	ELEMENT_INFO=$($PSQL "SELECT symbol, name FROM elements WHERE atomic_number = $1;")
	IFS=" " read SYMBOL NAME <<< "$(echo $ELEMENT_INFO | sed 's/|/ /')"
	ELEMENT_PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties INNER JOIN types USING (type_id) WHERE atomic_number = $1;")
	IFS=" " read MASS MELTING BOILING TYPE <<< "$(echo $ELEMENT_PROPERTIES | sed 's/|/ /g')"
	echo "The element with atomic number $1 is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
}

if [[ -z $1 ]]; then
	echo "Please provide an element as an argument."
else
	if [[ $1 =~ ^[A-Za-z].?$ ]]; then
		ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1';")
		if [[ -z $ATOMIC_NUMBER ]]; then
			echo $NOT_FOUND 
		else
			INFO $ATOMIC_NUMBER		
		fi
	elif [[ $1 =~ ^[0-9].?$ ]]; then
		ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1;")
		if [[ -z $ATOMIC_NUMBER ]]; then
			echo $NOT_FOUND
		else
			INFO $ATOMIC_NUMBER		
		fi
	elif [[ $1 =~ ^[A-Za-z]+[a-z]$ ]]; then
		ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1';")
		if [[ -z $ATOMIC_NUMBER ]]; then
			echo $NOT_FOUND
		else
			INFO $ATOMIC_NUMBER		
		fi
	else
		echo $NOT_FOUND
	fi
fi
