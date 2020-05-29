require'./test/test_helper'
require'./lib/stat_tracker'
require'csv'

class StatTrackerTest < Minitest::Test
  def setup
    @stat_tracker = StatTracker.from_csv({
      games: "./test/fixtures/games_fixture.csv",
      teams: "./data/teams.csv",
      game_teams: "./test/fixtures/game_teams_fixture.csv"})
  end

  def test_it_exists
    assert_instance_of StatTracker, @stat_tracker
  end

  def test_it_has_attributes

    assert_instance_of Game, @stat_tracker.games[0]
    assert Array, @stat_tracker.games
    assert_instance_of Team, @stat_tracker.teams[0]
    assert Array, @stat_tracker.teams
    assert_instance_of GameTeam, @stat_tracker.game_teams[0]
    assert Array, @stat_tracker.game_teams
  end

  def test_it_can_count_teams
    assert_equal 32, @stat_tracker.count_of_teams
  end

  def test_percentage_ties_is_found
    assert_equal 43.75, GameTeam.percentage_ties
  end


  def test_it_can_get_games_by_season
    expected = ({
                "20172018" => 16,
                "20132014" => 9,
                "20122013" => 7
                })
    assert_equal expected, @stat_tracker.count_of_games_by_season
  end

  def test_highest_and_lowest_total_game_score
    assert_equal 7, @stat_tracker.highest_total_score
    assert_equal 1, @stat_tracker.lowest_total_score
  end
end
