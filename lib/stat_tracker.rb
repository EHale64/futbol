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

  # game stats
  def highest_total_score
    Game.highest_total_score
  end

  def lowest_total_score
    Game.lowest_total_score
  end

  def percentage_home_wins
    home_wins = @game_teams.count {|game_team| game_team.result == "WIN" && game_team.hoa == "home"}
    average(home_wins, @game_teams.count/2)
  end

  def percentage_visitor_wins
    away_wins = @game_teams.count {|game_team| game_team.result == "WIN" && game_team.hoa == "away"}
    average(away_wins, @game_teams.count/2)
  end

  def percentage_ties
    ties = @game_teams.count { |team| team.result == "TIE" }
    average(ties, @game_teams.length)
  end

  def count_of_games_by_season
    games_by_season.transform_values { |season| season.length }
  end

  def average_goals_per_game
    goals = @game_teams.sum { |game| game.goals }
    average(goals, @game_teams.count/2)
  end

  def average_goals_by_season
    grouping = @games.group_by { |game| game.season }
    season_goals = grouping.transform_values do |games|
      games.map do |game|
        game.home_goals.to_f + game.away_goals
      end
    end
    season_goals.transform_values {|goals| average(goals.sum, goals.count)}
  end

  #league stats
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

  #season stats
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

    # team stats
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
    pct = win_percentage_against_all_teams(team_id)
    highest_pct = pct.max_by { |k,v| v}[1]
    all_teams = pct.find_all {|k,v| v == highest_pct}
    find_all_rival_or_favorite_opponents(all_teams)
  end

  def rival(team_id)
    pct = win_percentage_against_all_teams(team_id)
    lowest_pct = pct.min_by { |k,v| v}[1]
    all_teams = pct.find_all {|k,v| v == lowest_pct}
    all_rivals = all_teams.map {|team| team.first}
    all_rival_team_objects = all_rivals.map do |team_id|
      @teams.find {|team| team.team_id.to_i == team_id }
    end
    all_rival_teams = all_rival_team_objects.map {|team_obj| team_obj.teamname}.first
  end

    #helper methods
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

  def visitor_score
    grouped = Hash.new{|hash, key| hash[key] = []}
    away_games = @game_teams.select {|game_team| game_team.hoa == "away"}
    away_games.each {|game_team| grouped[game_team.team_id] << game_team.goals}
    avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  end

  def home_score
    grouped = Hash.new{|hash, key| hash[key] = []}
    home_games = @game_teams.select {|game_team| game_team.hoa == "home"}
    home_games.each {|game_team| grouped[game_team.team_id] << game_team.goals}
    avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
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

  def win_percentage_against_all_teams(team_id)
    win_percentage = {}
    @teams.each do |team|
      win_percentage[team.team_id.to_i] = []
    end

    find_wins_against_other_teams(team_id).each do |k,v|
      win_percentage[k] << v
    end

    find_losses_against_other_teams(team_id).each do |k,v|
      win_percentage[k] << v
    end

    relevant = win_percentage.delete_if do |k,v|
      v[0] == 0 && v[1] == 0
    end

    relevant.transform_values do |v|
        pct = (v[0] / (v[0] + v[1]).to_f)*100.round(2)
    end
  end

  def games_by_season
    games_by_season = @games.group_by { |game| game.season }
  end

  def seasonal_team_games(season)
    seasonal_game_ids = games_by_season[season].map { |game| game.game_id }
    @game_teams.find_all { |team| seasonal_game_ids.include?(team.game_id) }
  end

  def group_wins(games_by_coach)
    games_by_coach.transform_values do |array|
      wins = array.sum do |game|
        if game.result == "WIN"
          1
        else
          0
        end
      end
      wins.to_f / array.count
    end
  end

  def games_by_coach(season)
    seasonal_team_games(season).group_by do |game|
      game.head_coach
    end
  end

  def offense
    grouped = Hash.new{|hash, key| hash[key] = []}
    @game_teams.each do |game_team|
      grouped[game_team.team_id] << game_team.goals
    end
    avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  end

  def accuracy(season)
    team_results = seasonal_team_games(season).group_by { |team| team.team_id }
    accuracy = team_results.transform_values do |team|
      team.sum {|game| game.goals}.to_f / team.sum { |game| game.shots}
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
