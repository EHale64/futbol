require'./test/test_helper'
require'./lib/stat_tracker'

class StatTrackerTest < Minitest::Test
  def setup
    @stat_trackern = StatTracker.from_csv({
      games: "./test/fixtures/games_fixture.csv",
      teams: "./data/teams.csv",
      game_teams: "./test/fixtures/game_teams_fixture.csv"})
  end

  def test_it_exists
    assert_instance_of StatTracker, @stat_tracker
  end
end