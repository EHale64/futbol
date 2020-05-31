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

  def self.percentage_ties
    ties = @game_teams.count do |team|
      team.result == "TIE"
    end
    result = (ties.to_f / @game_teams.count)*100
    result.round(2)
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

  def average_goals_per_game
    goals = @game_teams.map do |game|
      game.goals
    end
    (goals.sum.to_f / @game_teams.count).round(2)
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

end
