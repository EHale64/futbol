require_relative "game"
require_relative "team"
require_relative "game_team"
require_relative "mathable"
require 'pry'

class StatTracker
  include Mathable
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

  def highest_total_score
    Game.highest_total_score
  end

  def lowest_total_score
    Game.lowest_total_score
  end

  def count_of_teams
    @teams.count
  end

  def best_offense
    best_offense = offense.max_by { |k,v| v}[0]
    team = @teams.find { |team| team.team_id.to_i == best_offense }.teamname
  end

  def worst_offense
    worst_offense = offense.min_by { |k,v| v}[0] ##Need to convert to team name
    team = @teams.find { |team| team.team_id.to_i == worst_offense }.teamname
  end

  def highest_scoring_visitor
    high_score_visitor = visitor_score.max_by { |k,v| v}[0]
    team = @teams.find {|team| team.team_id.to_i == high_score_visitor}.teamname
  end

  def lowest_scoring_visitor
    low_score_visitor = visitor_score.min_by { |k,v| v}[0]
    team = @teams.find {|team| team.team_id.to_i == low_score_visitor}.teamname
  end

  def highest_scoring_home_team
    high_score_home = home_score.max_by { |k,v| v}[0]
    team = @teams.find {|team| team.team_id.to_i == high_score_home}.teamname
  end

  def lowest_scoring_home_team
    low_score_home = home_score.min_by { |k,v| v}[0]
    team = @teams.find {|team| team.team_id.to_i == low_score_home}.teamname
  end

  def winningest_coach(season)
    wins = group_wins(games_by_coach(season))
    best_coach = wins.max_by { |coach, win_percent| win_percent }[0]
  end

  def worst_coach(season)
    wins = group_wins(games_by_coach(season))
    worst_coach = wins.min_by { |coach, win_percent| win_percent }[0]
  end

  def most_accurate_team(season)
    most_accurate = accuracy(season).max_by { |k, v| v}
    accurate_team = @teams.find {|team| team.team_id.to_i == most_accurate[0]}.teamname
  end

  def least_accurate_team(season)
    least_accurate = accuracy(season).min_by { |k, v| v}
    inaccurate_team = @teams.find {|team| team.team_id.to_i == least_accurate[0]}.teamname
  end

  def most_tackles(season)
    team_tackles(season).max_by {|team, tackles| tackles}[0]
  end

  def fewest_tackles(season)
    team_tackles(season).min_by {|team, tackles| tackles}[0]
  end

  def team_info(team_id)
    Team.team_info(team_id)
  end

  def best_season(team_id)
    winning_seasons(team_id)
    max_seasons_by_win = [winning_seasons(team_id).transform_values {|value| value.count}.invert.max].to_h.values.reduce
  end

  def worst_season(team_id)
    winning_seasons(team_id)
    min_seasons_by_win = [winning_seasons(team_id).transform_values {|value| value.count}.invert.min].to_h.values.reduce
  end

  def average_win_percentage(team_id)
    GameTeam.average_win_percentage(team_id)
  end

  def most_goals_scored(team_id)
    GameTeam.most_goals_scored(team_id)
  end

  def fewest_goals_scored(team_id)
    GameTeam.fewest_goals_scored(team_id)
  end

  def favorite_opponent(team_id)
    highest_pct = win_percentage_against_all_teams(team_id).max_by { |k,v| v}[1]
    all_teams = win_percentage_against_all_teams(team_id).find_all {|k,v| v == highest_pct}
    find_all_rival_or_favorite_opponents(all_teams)
  end

  def rival(team_id)
    lowest_pct = win_percentage_against_all_teams(team_id).min_by { |k,v| v}[1]
    all_teams = win_percentage_against_all_teams(team_id).find_all {|k,v| v == lowest_pct}
    all_rivals = all_teams.map {|team| team.first}
    all_rival_team_objects = all_rivals.map do |team_id|
      @teams.find {|team| team.team_id.to_i == team_id }
    end
    all_rival_teams = all_rival_team_objects.map {|team_obj| team_obj.teamname}.first
  end

  def won_games_id(given_team_id) #used to help best/worst season
    team = @game_teams.find_all {|team| team.team_id.to_i == given_team_id.to_i}
    game_wins = team.find_all {|info| info.result == "WIN"}
    game_win_id = game_wins.map {|info| info.game_id}
  end

  def winning_seasons(team_id)
    winning_seasons = []
    won_games_id(team_id).each do |game_id|
      @games.each do |game|
        if game.game_id == game_id
          winning_seasons << game.season
        end
      end
    end
    win_season_hash = winning_seasons.group_by {|season| season}
  end

  def find_all_rival_or_favorite_opponents(all_teams)
    all_teams = all_teams.map {|team| team.first}
    all_team_objects = all_teams.map do |team_id|
      @teams.find {|team| team.team_id.to_i == team_id }
    end
    all_team_objects.map {|team_obj| team_obj.teamname}.first
  end

  def find_wins_against_other_teams(team_id)
    team_id = team_id.to_i

    team_wins = @game_teams.select do |game_team|
      game_team.team_id == team_id && game_team.result == "WIN"
    end
    opponent_games_lost = team_wins.map do |game|
      @game_teams.select do |game_team|
        game_team.game_id == game.game_id
      end
    end.flatten
    opponent_games_lost.reject! {|game_team| game_team.team_id == team_id}

    losing_teams_game_count = {}
    @teams.each do |team|
      losing_teams_game_count[team.team_id.to_i] = []
    end

    opponent_games_lost.each do |game_team|
      losing_teams_game_count[game_team.team_id] << game_team
    end

    losing_teams_game_count.each do |k,v|
      losing_teams_game_count[k] = v.count
    end
  end

  def find_losses_against_other_teams(team_id)
    team_id = team_id.to_i
    team_losses = @game_teams.select do |game_team|
      game_team.team_id == team_id && game_team.result == "LOSS"
    end

    opponent_games_won = team_losses.map do |game|
      @game_teams.select do |game_team|
        game_team.game_id == game.game_id
      end
    end.flatten
    opponent_games_won.reject! {|game_team| game_team.team_id == team_id}

    winning_teams_game_count = {}
    @teams.each do |team|
      winning_teams_game_count[team.team_id.to_i] = []
    end

    opponent_games_won.each do |game_team|
      winning_teams_game_count[game_team.team_id] << game_team
    end

    winning_teams_game_count.each {|k,v| winning_teams_game_count[k] = v.count}
  end

  def games_by_season
    games_by_season = @games.group_by { |game| game.season }
  end

  def seasonal_team_games(season)
    seasonal_game_ids = games_by_season[season].map { |game| game.game_id }
    @game_teams.find_all { |team| seasonal_game_ids.include?(team.game_id) }
  end

  def games_by_coach(season)
    seasonal_team_games(season).group_by do |game|
      game.head_coach
    end
  end

  def team_tackles(season)
    season_games = seasonal_team_games(season)
    games_by_team = season_games.group_by { |game| game.team_id }
    games_by_team.transform_keys! do |team_id|
      correct_team = @teams.find do |team|
        team.team_id == team_id.to_s
      end
      correct_team.teamname
    end
    all_tackles = games_by_team.transform_values do |array|
      tackles = array.sum do |game|
        game.tackles
      end
      tackles
    end
  end
end
