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

  def team_info(team_id)
    Team.team_info(team_id)
  end

  def most_goals_scored(team_id)
    GameTeam.most_goals_scored(team_id)
  end

  def fewest_goals_scored(team_id)
    GameTeam.fewest_goals_scored(team_id)
  end

  def average_win_percentage(team_id)
    GameTeam.average_win_percentage(team_id)
  end

  def won_games_id(team_id)
    team = @game_teams.find_all do |team|
      team.team_id.to_i == team_id
    end
    game_wins = team.find_all do |info|
      info.result == "WIN"
    end
    game_win_id = game_wins.map {|info| info.game_id}
  end

  def best_season(team_id)
    winning_seasons = []
    won_games_id(team_id).each do |game_id|
      @games.each do |game|
        if game.game_id == game_id
          winning_seasons << game.season
        end
      end
    end
    win_season_hash = winning_seasons.group_by {|season| season}
    win_season_hash.transform_values {|value| value.count}.max[0]
  end

  def worst_season(team_id)
    winning_seasons = []
    won_games_id(team_id).each do |game_id|
      @games.each do |game|
        if game.game_id == game_id
          winning_seasons << game.season
        end
      end
    end
    win_season_hash = winning_seasons.group_by {|season| season}
    win_season_hash.transform_values {|value| value.count}.min[0]

end
