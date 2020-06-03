module Mathable

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
    season_goals = games_by_season.transform_values do |games|
      games.map { |game| game.home_goals.to_f + game.away_goals }
    end
    season_goals.transform_values { |goals| average(goals.sum, goals.count) }
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

  def average(numerator, denominator)
    (numerator.to_f / denominator).round(2)
  end
end
