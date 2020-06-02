require_relative'../test/test_helper'
require_relative'../lib/stat_tracker'
require'csv'
require 'pry'

class StatTrackerTest < Minitest::Test
  def setup
    @stat_tracker = StatTracker.from_csv({
      games: "./test/fixtures/games_fixture.csv",
      teams: "./data/teams.csv",
      game_teams: "./test/fixtures/game_teams_fixture.csv"
      })
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

  def test_highest_and_lowest_total_game_score
    assert_equal 7, @stat_tracker.highest_total_score
    assert_equal 1, @stat_tracker.lowest_total_score
  end

  def test_it_can_calculate_percentage_home_wins
    assert_equal 31.25, @stat_tracker.percentage_home_wins
  end

  def test_it_can_calculate_percentage_away_wins
    assert_equal 25.00, @stat_tracker.percentage_away_wins
  end

  def test_percentage_ties_is_found
    assert_equal 43.75, @stat_tracker.percentage_ties
  end

  def test_it_can_count_games_by_season
    expected = ({
      "20172018" => 16,
      "20132014" => 9,
      "20122013" => 7
      })
      assert_equal expected, @stat_tracker.count_of_games_by_season
  end

  def test_it_can_average_goals
    assert_equal 2.03, @stat_tracker.average_goals_per_game
  end

  def test_average_goals_by_season
    expected = {
      "20172018" => 4.5,
      "20132014" => 3.78,
      "20122013" => 5.0
    }
    assert_equal expected, @stat_tracker.average_goals_by_season
  end

  def test_it_can_count_teams
    assert_equal 32, @stat_tracker.count_of_teams
  end

  def test_it_can_find_best_offense
    assert_equal "Washington Spirit FC", @stat_tracker.best_offense
  end

  def test_it_can_find_worst_offense
    assert_equal "Philadelphia Union", @stat_tracker.worst_offense
  end

  def test_it_can_find_highest_scoring_visitor
    assert_equal "Washington Spirit FC", @stat_tracker.highest_scoring_visitor
  end

  def test_it_can_find_highest_scoring_home_team
    assert_equal "Real Salt Lake", @stat_tracker.highest_scoring_home_team
  end

  def test_it_can_find_lowest_scoring_visitor
    assert_equal "Philadelphia Union", @stat_tracker.lowest_scoring_visitor
  end

  def test_it_can_find_lowest_scoring_home_team
    assert_equal "Montreal Impact", @stat_tracker.lowest_scoring_home_team
  end

  def test_coach_win_rate
    assert_equal "Craig Berube", @stat_tracker.winningest_coach("2013")
    assert_equal "Ken Hitchcock", @stat_tracker.worst_coach("2013")
  end

  def test_it_can_find_most_accurate_team
    assert_equal "New York Red Bulls", @stat_tracker.most_accurate_team("20132014")
  end

  def test_it_can_find_least_accurate_team
    assert_equal "Philadelphia Union", @stat_tracker.least_accurate_team("20132014")
  end

  def test_tackle_volume_by_season
    assert_equal "North Carolina Courage", @stat_tracker.most_tackles("2013")
    assert_equal "Portland Timbers", @stat_tracker.fewest_tackles("2013")
  end

  def test_team_info
    expected = {
              "team_id" => "1",
              "franchise_id" => "23",
              "team_name" => "Atlanta United",
              "abbreviation" => "ATL",
              "link" => "/api/v1/teams/1"
            }
    assert_equal expected, @stat_tracker.team_info("1")
  end

  def test_best_and_worst_season_full_csv
    skip
    assert_equal "20122013", @stat_tracker.best_season(15)
    assert_equal "20152016", @stat_tracker.worst_season(15)
  end

  def test_average_win_percentage_for_team
    assert_equal 0.50, @stat_tracker.average_win_percentage("5")
  end

  def test_most_goals_scored_by_team
    assert_equal 3, @stat_tracker.most_goals_scored(15)
    assert_equal 3, @stat_tracker.most_goals_scored(5)
    assert_equal 3, @stat_tracker.most_goals_scored(7)
  end

  def test_fewest_goals_scored_by_team
    assert_equal 1, @stat_tracker.fewest_goals_scored(15)
    assert_equal 1, @stat_tracker.fewest_goals_scored(5)
    assert_equal 1, @stat_tracker.fewest_goals_scored(7)
  end

  def test_it_can_find_favorite_opponent
    assert_equal "Philadelphia Union", @stat_tracker.favorite_opponent("23")
  end

  def test_it_can_find_rivals
    assert_equal "North Carolina Courage", @stat_tracker.rival("23")
  end

  def test_won_games_id_for_team
    skip
    stat_tracker = StatTracker.from_csv({
      games: "./test/fixtures/games_fixture.csv",
      teams: "./data/teams.csv",
      # change fixture to get the result same for best/worst season
      game_teams: "./data/game_teams.csv"
      })
    expected = [2014020906, 2016020610, 2017020301,
                2016020560, 2017020953, 2017020058,
                2013020835]
    assert_equal expected, stat_tracker.won_games_id(15)
  end

  def test_it_can_track_wins_against_other_teams
    expected = { 1=>0, 4=>0, 26=>0, 14=>0,
                6=>0, 3=>0, 5=>0, 17=>0,
                28=>0, 18=>0, 23=>0, 16=>0,
                9=>0, 8=>0, 30=>0, 15=>0,
                19=>1, 24=>0, 27=>0, 2=>0,
                20=>0, 21=>0, 25=>0, 13=>0,
                10=>0, 29=>0, 52=>0, 54=>0,
                12=>0, 7=>0, 22=>0, 53=>0 }
    assert_equal expected, @stat_tracker.find_wins_against_other_teams("23")
  end

  def test_it_can_track_losses_against_other_teams
    expected = { 1=>0, 4=>0, 26=>0, 14=>0,
                6=>0, 3=>0, 5=>0, 17=>0,
                28=>0, 18=>0, 23=>0, 16=>0,
                9=>0, 8=>0, 30=>0, 15=>0,
                19=>0, 24=>0, 27=>0, 2=>0,
                20=>0, 21=>0, 25=>0, 13=>0,
                10=>1, 29=>0, 52=>0, 54=>0,
                12=>0, 7=>0, 22=>0, 53=>0 }
    assert_equal expected, @stat_tracker.find_losses_against_other_teams("23")
  end

  def test_it_can_find_winning_percentage_against_all_teams
    expected = { 19=>100.0, 10=>0.0 }
    assert_equal expected, @stat_tracker.win_percentage_against_all_teams("23")
  end

  def test_it_can_find_all_rival_or_favorite_opponents
    expected = "Toronto FC"
    argument = {20 => 0.5}
    assert_equal expected, @stat_tracker.find_all_rival_or_favorite_opponents(argument)
  end

  def test_it_can_get_games_by_season
    skip
    expected = ({
      "20172018" => [],
      "20132014" => [],
      "20122013" => []
      })
    assert_equal expected, @stat_tracker.games_by_season
  end

  def test_case_name
    skip
    expected = []
    assert_equal expected, @stat_tracker.seasonal_team_games("20132014")
  end
end
