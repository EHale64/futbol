require_relative 'loadable'

class Game
  @@accumulator = []
  extend Loadable
  attr_reader :game_id,
              :season,
              :type,
              :date_time,
              :away_team_id,
              :home_team_id,
              :away_goals,
              :home_goals,
              :venue,
              :venue_link

  def initialize(game_data)
    @game_id = game_data[:game_id].to_i
    @season = game_data[:season]
    @type = game_data[:type]
    @date_time = game_data[:date_time]
    @away_team_id = game_data[:away_team_id]
    @home_team_id = game_data[:home_team_id]
    @away_goals = game_data[:away_goals].to_i
    @home_goals = game_data[:home_goals].to_i
    @venue = game_data[:venue]
    @venue_link = game_data[:venue_link]
  end

  def self.from_csv(games_file_path)
    load_csv(games_file_path, self)
  end

  def self.accumulator
    @@accumulator
  end

  def average_goals_by_season
    grouping = @@accumulator.group_by do |game|
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

end
