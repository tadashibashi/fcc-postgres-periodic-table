#!/bin/bash
# Provides a terminal interface to query a database of scientific elements
# by Aaron Ishibashi
#
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# if no argument provided
if [[ $# -eq 0 ]]
then
	echo "Please provide an element as an argument."
	exit
fi

# parse user input
if [[ $1 =~ ^[0-9]+$ ]]               # number -> atomic_number
then
	QUERY_FIELD=atomic_number
	QUERY_PARAM=$1
elif [[ $1 =~ ^[A-Z][A-Za-z]{,1}$ ]]  # cap letter + letter -> symbol
then
	QUERY_FIELD="symbol"
	QUERY_PARAM="'$1'" # wrap in quotes, sql string type
else                                  # string -> element name
	QUERY_FIELD=name
	QUERY_PARAM="'$1'" # wrap in quotes, sql string type
fi

# perform the query
QUERY_RESULT=$($PSQL "SELECT name, atomic_number, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING (type_id) WHERE $QUERY_FIELD=$QUERY_PARAM")

# if nothing was returned
if [[ -z $QUERY_RESULT ]]
then
	echo "I could not find that element in the database."
	exit
fi

# display result
echo "$QUERY_RESULT" | while read NAME BAR ATOMIC_NUMBER BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT
do
	echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
	exit
done
