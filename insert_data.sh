#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#insert into teams table
tail -n +2 games.csv | cut -d',' -f3,4 | tr ',' '\n' | sort | uniq | while read team
do
 if [[ -n "$team" ]]; then
   $PSQL "INSERT INTO teams(name) VALUES ('$team');"
   echo "Inserted: $team"
 fi
done

#insert into games table
tail -n +2 games.csv | while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  # Get team IDs from teams table
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")

  # Insert into games table
  if [[ -n "$winner_id" && -n "$opponent_id" ]]; then
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
    echo "Inserted game: $year $round - $winner vs $opponent ($winner_goals:$opponent_goals)"
  else
    echo "Error: Could not find team_id for $winner or $opponent"
  fi
done
