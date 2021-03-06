require 'csv'
require_relative '../test/test_helper'
require_relative '../lib/game_team'

class GameTeamTest < Minitest::Test

  def setup

    expected = ({
      game_id: 2012020511,
      team_id: 15,
      hoa: "away",
      result: "TIE",
      settled_in: "SO",
      head_coach: "Adam Oates",
      goals: 3,
      shots: 9,
      tackles: 19,
      pim: 6,
      powerplayopportunities: 4,
      powerplaygoals: 1,
      faceoffwinpercentage: 52.5,
      giveaways: 3,
      takeaways: 2
    })
    @game_team = GameTeam.new(expected)
    GameTeam.from_csv("./test/fixtures/game_teams_fixture.csv")
    @game_team_2 = GameTeam.accumulator[5]
    @games_teams = GameTeam.accumulator
  end

  def test_it_exists
    assert_instance_of GameTeam, @game_team
  end

  def test_it_has_readable_attributes
    assert_equal 2012020511, @game_team.game_id
    assert_equal 15, @game_team.team_id
    assert_equal "away", @game_team.hoa
    assert_equal "TIE", @game_team.result
    assert_equal "SO", @game_team.settled_in
    assert_equal "Adam Oates", @game_team.head_coach
    assert_equal 3, @game_team.goals
    assert_equal 9, @game_team.shots
    assert_equal 19, @game_team.tackles
    assert_equal 6, @game_team.pim
    assert_equal 4, @game_team.powerplayopportunities
    assert_equal 1, @game_team.powerplaygoals
    assert_equal 52.5, @game_team.faceoffwinpercentage
    assert_equal 3, @game_team.giveaways
    assert_equal 2, @game_team.takeaways
  end

  def test_it_can_read_from_csv
    assert_instance_of GameTeam, @game_team_2

    assert_equal 2013020885, @game_team_2.game_id
    assert_equal 23, @game_team_2.team_id
    assert_equal "home", @game_team_2.hoa
    assert_equal "WIN", @game_team_2.result
    assert_equal "REG", @game_team_2.settled_in
    assert_equal "John Tortorella", @game_team_2.head_coach
    assert_equal 1, @game_team_2.goals
    assert_equal 8, @game_team_2.shots
    assert_equal 18, @game_team_2.tackles
    assert_equal 6, @game_team_2.pim
    assert_equal 4, @game_team_2.powerplayopportunities
    assert_equal 0, @game_team_2.powerplaygoals
    assert_equal 53.6, @game_team_2.faceoffwinpercentage
    assert_equal 9, @game_team_2.giveaways
    assert_equal 6, @game_team_2.takeaways
  end

  def test_it_can_find_tie_percentage
    assert_equal 43.75, GameTeam.percentage_ties
  end

  def test_it_can_calculate_percentage_home_wins
    assert_equal 31.25, GameTeam.percentage_home_wins
  end

  def test_it_can_calculate_percentage_home_wins
    assert_equal 25.00, GameTeam.percentage_away_wins
  end

  def test_it_can_average_goals
    assert_equal 2.03, GameTeam.average_goals_per_game
  end

  def test_most_goals_scored_by_team
    assert_equal 3, GameTeam.most_goals_scored(15)
    assert_equal 3, GameTeam.most_goals_scored(5)
    assert_equal 3, GameTeam.most_goals_scored(7)
  end

  def test_fewest_goals_scored_by_team
    assert_equal 1, GameTeam.fewest_goals_scored(15)
    assert_equal 1, GameTeam.fewest_goals_scored(5)
    assert_equal 1, GameTeam.fewest_goals_scored(7)
  end

  def test_average_win_percentage_for_team
    assert_equal 0.50, GameTeam.average_win_percentage("5")
  end

end
