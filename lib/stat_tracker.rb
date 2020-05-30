require_relative "game"
require_relative "team"
require_relative "game_team"

class StatTracker
  attr_reader :games, :teams, :game_teams

  def self.from_csv(locations)
    @games_file_path = locations[:games]
    @teams_file_path = locations[:teams]
    @game_teams_file_path = locations[:game_teams]
    StatTracker.new(@games_file_path, @teams_file_path, @game_teams_file_path)
  end

  def initialize(games_path, teams_path, game_teams_path)
    Game.from_csv(games_path)
    Team.from_csv(teams_path)
    GameTeam.from_csv(game_teams_path)

    @games = Game.accumulator
    @teams = Team.accumulator
    @game_teams = GameTeam.accumulator
  end

  def count_of_teams
    Team.accumulator.count
  end

  def percentage_ties
    GameTeam.percentage_ties
  end

  def highest_total_score
    Game.highest_total_score
  end

  def lowest_total_score
    Game.lowest_total_score
  end

  def count_of_games_by_season
    games_by_season = @games.group_by do |game|
       game.season
     end
    games_by_season.transform_values { |season| season.length }
  end

  def percentage_home_wins
    GameTeam.percentage_home_wins
  end

  def percentage_away_wins
    GameTeam.percentage_away_wins
  end

  def winningest_coach(season)
    season_games = @game_teams.find_all do |game|
      game.game_id.to_s[0..3] == season
    end
    games_by_coach = season_games.group_by do |game|
      game.head_coach
    end
    wins = games_by_coach.transform_values do |array|
      wins = array.sum do |game|
        if game.result == "WIN"
          1
        else
          0
        end
      end
      wins.to_f / array.count
    end
    best_coach = wins.max_by do |coach, win_percent|
      win_percent
    end
    best_coach[0]
  end

  def worst_coach(season)
    season_games = @game_teams.find_all do |game|
      game.game_id.to_s[0..3] == season
    end
    games_by_coach = season_games.group_by do |game|
      game.head_coach
    end
    wins = games_by_coach.transform_values do |array|
      wins = array.sum do |game|
        if game.result == "WIN"
          1
        else
          0
        end
      end
      wins.to_f / array.count
    end
    worst_coach = wins.min_by do |coach, win_percent|
      win_percent
    end
    worst_coach[0]
  end
end
