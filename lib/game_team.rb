require_relative 'loadable'

class GameTeam
  extend Loadable
  attr_reader :game_id, :team_id, :hoa, :result, :settled_in,
              :head_coach, :goals, :shots, :tackles, :pim,
              :powerplayopportunities, :powerplaygoals,
              :faceoffwinpercentage, :giveaways, :takeaways

  def initialize(data)
    @game_id = data[:game_id].to_i
    @team_id = data[:team_id].to_i
    @hoa = data[:hoa]
    @result = data[:result]
    @settled_in = data[:settled_in]
    @head_coach = data[:head_coach]
    @goals = data[:goals].to_i
    @shots  = data[:shots].to_i
    @tackles = data[:tackles].to_i
    @pim = data[:pim].to_i
    @powerplayopportunities = data[:powerplayopportunities].to_i
    @powerplaygoals = data[:powerplaygoals].to_i
    @faceoffwinpercentage = data[:faceoffwinpercentage].to_f
    @giveaways = data[:giveaways].to_i
    @takeaways = data[:takeaways].to_i
  end

 def self.from_csv(games_file_path)
   @@accumulator = []
   load_csv(games_file_path, self)
 end

 def self.accumulator
   @@accumulator
 end

 def self.percentage_ties
   ties = @@accumulator.count do |team|
     team.result == "TIE"
   end
   result = (ties.to_f / @@accumulator.count)*100
   result.round(2)
 end

 def percentage_home_wins
   home_wins = @@accumulator.count do |game_team|
     game_team.result == "WIN" && game_team.hoa == "home"
   end
   result = (home_wins.to_f / (@@accumulator.count/2))*100
   result.round(2)
 end

 def percentage_away_wins
   away_wins = @@accumulator.count do |game_team|
     game_team.result == "WIN" && game_team.hoa == "away"
   end
   result = (away_wins.to_f / (@@accumulator.count/2))*100
   result.round(2)
 end

 def average_goals_per_game
   goals = @@accumulator.map do |game|
     game.goals
   end
   (goals.sum.to_f / @@accumulator.count).round(2)
 end

 def best_offense
  grouped = Hash.new{|hash, key| hash[key] = []}
  @@accumulator.each do |game_team|
    grouped[game_team.team_id] << game_team.goals
  end

  avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  best_offense = avg_score.max_by { |k,v| v}
  best_offense = best_offense[0] ##Need to convert to team name
end

def worst_offense
  grouped = Hash.new{|hash, key| hash[key] = []}
  @@accumulator.each do |game_team|
    grouped[game_team.team_id] << game_team.goals
  end

  avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  worst_offense = avg_score.min_by { |k,v| v}
  worst_offense = worst_offense[0] ##Need to convert to team name


end

def highest_scoring_home_team
  grouped = Hash.new{|hash, key| hash[key] = []}

  home_games = @@accumulator.select do |game_team|
    game_team.hoa == "home"
  end
  home_games.each do |game_team|
    grouped[game_team.team_id] << game_team.goals
  end

  avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  high_score_home = avg_score.max_by { |k,v| v}
  high_score_home = high_score_home[0] ##Need to convert to team name
end

def highest_scoring_visitor
  grouped = Hash.new{|hash, key| hash[key] = []}

  away_games = @@accumulator.select do |game_team|
    game_team.hoa == "away"
  end
  away_games.each do |game_team|
    grouped[game_team.team_id] << game_team.goals
  end

  avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  high_score_visitor = avg_score.max_by { |k,v| v}
  high_score_visitor = high_score_visitor[0] ##Need to convert to team name
end

def lowest_scoring_visitor
  grouped = Hash.new{|hash, key| hash[key] = []}

  away_games = @@accumulator.select do |game_team|
    game_team.hoa == "away"
  end
  away_games.each do |game_team|
    grouped[game_team.team_id] << game_team.goals
  end

  avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  low_score_visitor = avg_score.min_by { |k,v| v}
  low_score_visitor = low_score_visitor[0] ##Need to convert to team name
end

def lowest_scoring_home_team
  grouped = Hash.new{|hash, key| hash[key] = []}

  home_games = @@accumulator.select do |game_team|
    game_team.hoa == "home"
  end
  home_games.each do |game_team|
    grouped[game_team.team_id] << game_team.goals
  end

  avg_score = grouped.map { |k,v| [k, (v.sum / v.count.to_f) ]}
  low_score_home = avg_score.min_by { |k,v| v}
  low_score_home = low_score_home[0] ##Need to convert to team name
end

end
