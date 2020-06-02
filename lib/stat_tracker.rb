require_relative "game"
require_relative "team"
require_relative "game_team"
require 'pry'

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
  # game stats

  def highest_total_score
    Game.highest_total_score
  end

  def lowest_total_score
    Game.lowest_total_score
  end

  def percentage_home_wins
    home_wins = @game_teams.count do |game_team|
      game_team.result == "WIN" && game_team.hoa == "home"
    end
    result = (home_wins.to_f / (@game_teams.count/2))*100
    result.round(2)
  end

  def percentage_away_wins
    away_wins = @game_teams.count do |game_team|
      game_team.result == "WIN" && game_team.hoa == "away"
    end
    result = (away_wins.to_f / (@game_teams.count/2))*100
    result.round(2)
  end

  def percentage_ties
    ties = @game_teams.count do |team|
      team.result == "TIE"
    end
    result = (ties.to_f / @game_teams.count)*100
    result.round(2)
  end

  def count_of_games_by_season
    games_by_season
    games_by_season.transform_values { |season| season.length }
  end

  def average_goals_per_game
    goals = @game_teams.map do |game|
      game.goals
    end
    (goals.sum.to_f / @game_teams.count).round(2)
  end

  def average_goals_by_season
    grouping = @games.group_by do |game|
      game.season
    end
    season_goals = grouping.transform_values do |games|
      games.map do |game|
        game.home_goals.to_f + game.away_goals
      end
    end
    season_goals.transform_values do |goals|
      (goals.sum / goals.count).round(2)
    end
  end

#league stats

  def count_of_teams
    Team.accumulator.count
  end

  def best_offense
    grouped = Hash.new{|hash, key| hash[key] = []}
    @game_teams.each do |game_team|
      grouped[game_team.team_id] << game_team.goals
    end

    avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
    best_offense = avg_score.max_by { |k,v| v}
    best_offense = best_offense[0]

    team = @teams.find do |team|
      team.team_id.to_i == best_offense
    end
    team.teamname
  end

def worst_offense
  grouped = Hash.new{|hash, key| hash[key] = []}
  @game_teams.each do |game_team|
    grouped[game_team.team_id] << game_team.goals
  end

  avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  worst_offense = avg_score.min_by { |k,v| v}
  worst_offense = worst_offense[0] ##Need to convert to team name

  team = @teams.find do |team|
    team.team_id.to_i == worst_offense
  end
  team.teamname
end

def highest_scoring_visitor
  grouped = Hash.new{|hash, key| hash[key] = []}

  away_games = @game_teams.select do |game_team|
    game_team.hoa == "away"
  end
  away_games.each do |game_team|
    grouped[game_team.team_id] << game_team.goals
  end

  avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  high_score_visitor = avg_score.max_by { |k,v| v}
  high_score_visitor = high_score_visitor[0]

  team = @teams.find do |team|
    team.team_id.to_i == high_score_visitor
  end
  team.teamname
end

def highest_scoring_home_team
  grouped = Hash.new{|hash, key| hash[key] = []}

  home_games = @game_teams.select do |game_team|
    game_team.hoa == "home"
  end
  home_games.each do |game_team|
    grouped[game_team.team_id] << game_team.goals
  end

  avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  high_score_home = avg_score.max_by { |k,v| v}
  high_score_home = high_score_home[0]

  team = @teams.find do |team|
    team.team_id.to_i == high_score_home
  end
  team.teamname
end

def lowest_scoring_visitor
  grouped = Hash.new{|hash, key| hash[key] = []}

  away_games = @game_teams.select do |game_team|
    game_team.hoa == "away"
  end
  away_games.each do |game_team|
    grouped[game_team.team_id] << game_team.goals
  end

  avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  low_score_visitor = avg_score.min_by { |k,v| v}
  low_score_visitor = low_score_visitor[0]

  team = @teams.find do |team|
    team.team_id.to_i == low_score_visitor
  end
  team.teamname
end

def lowest_scoring_home_team
  grouped = Hash.new{|hash, key| hash[key] = []}

  home_games = @game_teams.select do |game_team|
    game_team.hoa == "home"
  end
  home_games.each do |game_team|
    grouped[game_team.team_id] << game_team.goals
  end

  avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  low_score_home = avg_score.min_by { |k,v| v}
  low_score_home = low_score_home[0]

  team = @teams.find do |team|
    team.team_id.to_i == low_score_home
  end
  team.teamname
end

#season stats
def winningest_coach(season)
   wins = group_wins(games_by_coach(season))
  best_coach = wins.max_by do |coach, win_percent|
    win_percent
  end
  best_coach[0]
end

def worst_coach(season)
   wins = group_wins(games_by_coach(season))
  worst_coach = wins.min_by do |coach, win_percent|
    win_percent
  end
  worst_coach[0]
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

def least_accurate_team(season)
  team_results = seasonal_team_games(season).group_by do |team|
    team.team_id
  end
  accuracy = team_results.transform_values do |team|
    team.sum {|game| game.goals}.to_f / team.sum { |game| game.shots}
  end
  least_accurate = accuracy.min_by { |k, v| v}
  inaccurate_team = @teams.find do |team|
    team.team_id.to_i == least_accurate[0]
  end
  inaccurate_team.teamname
end

def most_tackles(season)
  season_games = seasonal_team_games(season)
  games_by_team = season_games.group_by do |game|
    game.team_id
  end
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
  most_tackles = all_tackles.max_by do |team, tackles|
    tackles
  end
  most_tackles[0]
end

def fewest_tackles(season)
  season_games = @game_teams.find_all do |game|
    game.game_id.to_s[0..3] == season
  end
  games_by_team = season_games.group_by do |game|
    game.team_id
  end
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
  least_tackles = all_tackles.min_by do |team, tackles|
    tackles
  end
  least_tackles[0]
end

# team info
def team_info(team_id)
  Team.team_info(team_id)
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
    max_seasons_by_win = win_season_hash.transform_values {|value| value.count}.invert.max
    [max_seasons_by_win].to_h.values.reduce
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
    min_seasons_by_win = win_season_hash.transform_values {|value| value.count}.invert.min
    [min_seasons_by_win].to_h.values.reduce
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

  def favorite_opponent(team_name)
    pct = win_percentage_against_all_teams(team_name)
    pct.delete_if { |k,v| v.class == String}

    highest_pct = pct.max_by { |k,v| v}[1]

    all_favorites = pct.find_all do |k,v|
      v == highest_pct
    end

    all_favorites = all_favorites.map do |team|
      team.first
    end

    all_favorite_team_objects = all_favorites.map do |team_id|
      @teams.find {|team| team.team_id.to_i == team_id }
    end

    all_favorite_teams = all_favorite_team_objects.map do |team_obj|
      team_obj.teamname
    end
    all_favorite_teams
  end

  def rival(team_name)
    pct = win_percentage_against_all_teams(team_name)
    pct.delete_if { |k,v| v.class == String}

    lowest_pct = pct.min_by { |k,v| v}[1]

    all_rivals = pct.find_all do |k,v|
      v == lowest_pct
    end

    all_rivals = all_rivals.map do |team|
      team.first
    end

    all_rival_team_objects = all_rivals.map do |team_id|
      @teams.find {|team| team.team_id.to_i == team_id }
    end

    all_rival_teams = all_rival_team_objects.map do |team_obj|
      team_obj.teamname
    end
    all_rival_teams
  end

  #helper methods
  def won_games_id(given_team_id)
    team = @game_teams.find_all do |team|
      team.team_id.to_i == given_team_id
    end
    game_wins = team.find_all do |info|
      info.result == "WIN"
    end
    game_win_id = game_wins.map {|info| info.game_id}
  end

  def find_wins_against_other_teams(team_name)
    team = @teams.find {|team| team.teamname == team_name }
    team_id = team.team_id.to_i

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

  def find_losses_against_other_teams(team_name)
    team = @teams.find {|team| team.teamname == team_name }
    team_id = team.team_id.to_i
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

  def win_percentage_against_all_teams(team_name)
    hash = {}
    @teams.each do |team|
      hash[team.team_id.to_i] = []
    end

    find_wins_against_other_teams(team_name).each do |k,v|
      hash[k] << v
    end

    find_losses_against_other_teams(team_name).each do |k,v|
      hash[k] << v
    end

    win_percentage_hash = hash.transform_values do |v|
      if v[0] == 0 && v[1] == 0
        "NA"
      else
        pct = v[0] / (v[0] + v[1]).to_f
        pct = (pct * 100).round(2)
      end
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

end
