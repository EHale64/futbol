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
    games_by_season
    games_by_season.transform_values { |season| season.length }
  end

  def percentage_home_wins
    GameTeam.percentage_home_wins
  end

  def percentage_away_wins
    GameTeam.percentage_away_wins
  end

  def games_by_season
    games_by_season = @games.group_by { |game| game.season }
  end

  def seasonal_team_games(season)
    seasonal_game_ids = games_by_season[season].map { |game| game.game_id }
    @game_teams.find_all { |team| seasonal_game_ids.include?(team.game_id) }
  end

  def most_accurate_team(season)
    team_results = seasonal_team_games(season).group_by do |team|
      team.team_id
    end
    accuracy = team_results.transform_values do |team|
      team.sum {|game| game.goals}.to_f / team.sum { |game| game.shots}
    end
    most_accurate = accuracy.max_by { |k, v| v}
    accurate_team = @teams.find do |team|
      team.team_id.to_i == most_accurate[0]
    end
    accurate_team.teamname
  end
end
