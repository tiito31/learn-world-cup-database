#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo -e $($PSQL "TRUNCATE teams, games")

echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")
echo -e

# year,round,winner,opponent,winner_goals,opponent_goals
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" ]]
  then
    #get teams_id
    TEAM_ID_WI=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    #if not found
    if [[ -z $TEAM_ID_WI ]]
    then
      # insert team winner
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Insert into teams, $WINNER
      fi
      #get new team id
      TEAM_ID_WI=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
  fi

  if [[ $OPPONENT != "opponent" ]]
  then
    #get teams_id
    TEAM_ID_OP=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    #if not found
    if [[ -z $TEAM_ID_OP ]]
    then
      # insert team winner
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Insert into teams, $OPPONENT
      fi
      #get new team id
      TEAM_ID_OP=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  fi

  #insert into games
  INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($YEAR, '$ROUND', $TEAM_ID_WI, $TEAM_ID_OP, $WINNER_GOALS, $OPPONENT_GOALS)")
  if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
  then
    echo Insert into games, $YEAR, $ROUND, $TEAM_ID_WI, $TEAM_ID_OP, $WINNER_GOALS, $OPPONENT_GOALS
  fi
done