require './test/test_helper'
require './lib/team'
require 'csv'

class TeamTest < Minitest::Test

  def setup
    team_data = {team_id: 1,
                franchiseid: 23,
                teamname: "Atlanta United",
                abbreviation: "ATL",
                stadium: "Mercedes_Benz Stadium",
                link: "/api/v1/teams/1"
              }

    @team = Team.new(team_data)
    Team.from_csv('./data/teams.csv')
    @team_1 = Team.accumulator[5]
  end

  def test_its_values
    assert_equal 1, @team.team_id
    assert_equal 23, @team.franchiseid
    assert_equal "Atlanta United", @team.teamname
    assert_equal "ATL", @team.abbreviation
    assert_equal "Mercedes_Benz Stadium", @team.stadium
    assert_equal "/api/v1/teams/1", @team.link
  end

  def test_it_can_pull_from_csv
    assert_equal "3", @team_1.team_id
    assert_equal "10", @team_1.franchiseid
    assert_equal "Houston Dynamo", @team_1.teamname
    assert_equal "HOU", @team_1.abbreviation
    assert_equal "BBVA Stadium", @team_1.stadium
    assert_equal "/api/v1/teams/3", @team_1.link
  end

  def test_team_info
    expected = {
              team_id: 1,
              franchiseId: 23,
              teamName: "Atlanta United",
              abbreviation: "ATL",
              link: "/api/v1/teams/1"
            }
    assert_equal expected, Team.team_info(1)

    expected = {
              team_id: 28,
              franchiseId: 29,
              teamName: "Los Angeles FC",
              abbreviation: "LFC",
              link: "/api/v1/teams/28"
            }
    assert_equal expected, Team.team_info(28)
  end
end
