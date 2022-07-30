#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
TRUNCATE=$($PSQL "TRUNCATE teams, games;")
if [[ $TRUNCATE == "TRUNCATE TABLE" ]]; then
  echo -e "-------------------DATA ELIMINATED-------------------\n"
fi

sleep 1
echo "-------------------BEGINING PROCESS-------------------"
sleep 2

cat games.csv | while IFS="," read YEAR ROUND COUNTRY OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $COUNTRY == winner ]]; then
    echo -e "\n-------------------INSERTING TEAMS-------------------\n"
  else
    WINNER_INSERTED=$($PSQL "INSERT INTO teams(name) VALUES('$COUNTRY');" 2>/dev/null) 
    OPPONENT_INSERTED=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');" 2>/dev/null)

    if [[ $WINNER_INSERTED != "INSERT 0 1" ]]; then
      echo "-$COUNTRY inserted"
    fi
    if [[ $OPPONENT_INSERTED == "INSERT 0 1" ]]; then
      echo "-$OPPONENT inserted"
    fi
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR == year ]]; then
    echo -e "\n-------------------INSERTING GAMES-------------------\n"
    sleep 1
  else
    WINNERID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPONENTID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    GAME_INSERTED=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNERID, $OPPONENTID, $WINNER_GOALS, $OPPONENT_GOALS);")
    if [[ $GAME_INSERTED == "INSERT 0 1" ]]; then
      echo "-Game inserted"
    fi
  fi
done