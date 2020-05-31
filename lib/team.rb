require_relative 'loadable'

class Team
  extend Loadable
  attr_reader :team_id,
              :franchiseid,
              :teamname,
              :abbreviation,
              :stadium,
              :link

  def initialize(team_info)
    @team_id = team_info[:team_id]
    @franchiseid = team_info[:franchiseid]
    @teamname = team_info[:teamname]
    @abbreviation = team_info[:abbreviation]
    @stadium = team_info[:stadium]
    @link = team_info[:link]
  end

  def self.from_csv(games_file_path)
    @@accumulator = []
    load_csv(games_file_path, self)
  end

  def self.accumulator
    @@accumulator
  end

  def self.team_info(team_id)
    team = @@accumulator.find_all do |team|
      team.team_id.to_i == team_id
    end
    team_info = {
      team_id: team.reduce.team_id.to_i,
      franchiseId: team.reduce.franchiseid.to_i,
      teamName: team.reduce.teamname,
      abbreviation: team.reduce.abbreviation,
      link: team.reduce.link}
  end
end
