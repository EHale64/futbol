module Helpable

  def won_games_id(given_team_id) #used to help best/worst season
    team = @game_teams.find_all {|team| team.team_id.to_i == given_team_id.to_i}
    game_wins = team.find_all {|info| info.result == "WIN"}
    game_win_id = game_wins.map {|info| info.game_id}
  end

  def winning_seasons(team_id)
    winning_seasons = []
    won_games_id(team_id).each do |game_id|
      @games.each do |game|
        winning_seasons << game.season if game.game_id == game_id
      end
    end
    win_season_hash = winning_seasons.group_by {|season| season}
  end

  def find_all_rival_or_favorite_opponents(all_teams)
    all_teams = all_teams.map {|team| team.first}
    all_team_objects = all_teams.map do |team_id|
      @teams.find {|team| team.team_id.to_i == team_id }
    end
    all_team_objects.map {|team_obj| team_obj.teamname}.first
  end

  def find_wins_against_other_teams(team_id)
    team_id = team_id.to_i
    team_wins = @game_teams.select do |game_team|
      game_team.team_id == team_id && game_team.result == "WIN"
    end
    opponent_games_lost = team_wins.map do |game|
      @game_teams.select do |game_team|
        game_team.game_id == game.game_id
      end
    end.flatten
    opponent_games_lost.reject! {|game_team| game_team.team_id == team_id}
    losing_teams_game_count = {}
    @teams.each do |team|
      losing_teams_game_count[team.team_id.to_i] = []
    end
    opponent_games_lost.each do |game_team|
      losing_teams_game_count[game_team.team_id] << game_team
    end
    losing_teams_game_count.each do |k,v|
      losing_teams_game_count[k] = v.count
    end
  end

  def find_losses_against_other_teams(team_id)
    team_id = team_id.to_i
    team_losses = @game_teams.select do |game_team|
      game_team.team_id == team_id && game_team.result == "LOSS"
    end

    opponent_games_won = team_losses.map do |game|
      @game_teams.select do |game_team|
        game_team.game_id == game.game_id
      end
    end.flatten
    opponent_games_won.reject! {|game_team| game_team.team_id == team_id}

    winning_teams_game_count = {}
    @teams.each do |team|
      winning_teams_game_count[team.team_id.to_i] = []
    end
    opponent_games_won.each do |game_team|
      winning_teams_game_count[game_team.team_id] << game_team
    end
    winning_teams_game_count.each {|k,v| winning_teams_game_count[k] = v.count}
  end

  def games_by_season
    games_by_season = @games.group_by { |game| game.season }
  end

  def seasonal_team_games(season)
    seasonal_game_ids = games_by_season[season].map { |game| game.game_id }
    @game_teams.find_all { |team| seasonal_game_ids.include?(team.game_id) }
  end

  def games_by_coach(season)
    seasonal_team_games(season).group_by do |game|
      game.head_coach
    end
  end

  def team_tackles(season)
    season_games = seasonal_team_games(season)
    games_by_team = season_games.group_by { |game| game.team_id }
    games_by_team.transform_keys! do |team_id|
      correct_team = @teams.find do |team|
        team.team_id == team_id.to_s
      end
      correct_team.teamname
    end
    all_tackles = games_by_team.transform_values do |array|
      tackles = array.sum do |game|
        game.tackles
      end
      tackles
    end
  end
end
