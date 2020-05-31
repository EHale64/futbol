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

  def test_it_can_count_teams
    assert_equal 32, @stat_tracker.count_of_teams
  end

  def test_percentage_ties_is_found
    assert_equal 43.75, @stat_tracker.percentage_ties
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

  def test_coach_win_rate
    assert_equal "Craig Berube", @stat_tracker.winningest_coach("2013")
    assert_equal "Ken Hitchcock", @stat_tracker.worst_coach("2013")
  end

  def test_tackle_volume_by_season
    assert_equal "North Carolina Courage", @stat_tracker.most_tackles("2013")
    assert_equal "Portland Timbers", @stat_tracker.fewest_tackles("2013")

  # def test_it_can_find_tie_percentage
  #   assert_equal 43.75, @stat_tracker.percentage_ties
  # end

  def test_it_can_calculate_percentage_home_wins
    assert_equal 31.25, @stat_tracker.percentage_home_wins
  end

  def test_it_can_calculate_percentage_home_wins
    assert_equal 25.00, @stat_tracker.percentage_away_wins
  end

  def test_it_can_average_goals
    assert_equal 2.03, @stat_tracker.average_goals_per_game
  end

  def test_it_can_find_best_offense
    assert_equal "Washington Spirit FC", @stat_tracker.best_offense
  end

  def test_it_can_find_worst_offense
    assert_equal "Philadelphia Union", @stat_tracker.worst_offense
  end

  def test_it_can_find_highest_scoring_home_team
    assert_equal "Real Salt Lake", @stat_tracker.highest_scoring_home_team
  end

  def test_it_can_find_highest_scoring_visitor
    assert_equal "Washington Spirit FC", @stat_tracker.highest_scoring_visitor
  end

  def test_it_can_find_lowest_scoring_visitor
    assert_equal "Philadelphia Union", @stat_tracker.lowest_scoring_visitor
  end

  def test_it_can_find_lowest_scoring_home_team
    assert_equal "Montreal Impact", @stat_tracker.lowest_scoring_home_team
  end

  def test_it_can_find_most_accurate_team
    assert_equal "New York Red Bulls", @stat_tracker.most_accurate_team("20132014")
  end

  def test_it_can_find_least_accurate_team
    assert_equal "Philadelphia Union", @stat_tracker.least_accurate_team("20132014")
  def test_team_info
    expected = {
              team_id: 1,
              franchiseId: 23,
              teamName: "Atlanta United",
              abbreviation: "ATL",
              link: "/api/v1/teams/1"
            }
    assert_equal expected, @stat_tracker.team_info(1)

    expected = {
              team_id: 28,
              franchiseId: 29,
              teamName: "Los Angeles FC",
              abbreviation: "LFC",
              link: "/api/v1/teams/28"
            }
    assert_equal expected, @stat_tracker.team_info(28)
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

  def test_average_win_percentage_for_team
    assert_equal 50.00, @stat_tracker.average_win_percentage(5)
    assert_equal 0, @stat_tracker.average_win_percentage(7)
  end

  def test_won_games_id_for_team
    expected = [2014020906, 2016020610, 2017020301,
                2016020560, 2017020953, 2017020058,
                2013020835]
    assert_equal expected, @stat_tracker.won_games_id(15)
  end

  def test_best_and_worst_season_full_csv
    skip
    assert_equal "20152016", @stat_tracker.best_season(15)
    assert_equal "20132014", @stat_tracker.worst_season(15)
  end


  end

  def test_it_can_track_wins_against_other_teams
skip
    expected = {13 => 1}
    assert_equal expected, @stat_tracker.find_wins_against_other_teams("Montreal Impact")
  end

  def test_it_can_track_losses_against_other_teams
skip
    expected = {5 => 1}
    assert_equal expected, @stat_tracker.find_losses_against_other_teams("Montreal Impact")
  end

  def test_it_can_find_winning_percentage_against_all_teams
skip
    assert_equal "Houston Dash", @stat_tracker.win_percentage_against_all_teams("Montreal Impact")
  end

  def test_it_can_find_favorite_opponent
    assert_equal ["Philadelphia Union"], @stat_tracker.favorite_opponent("Montreal Impact")
  end

  def test_it_can_find_rivals
    assert_equal ["North Carolina Courage"], @stat_tracker.rival("Montreal Impact")
  end

end
