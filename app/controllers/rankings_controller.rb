class RankingsController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    id = current_user.id.to_s

    if params[:type] == "everyone"
      rankings = Ranking.for_everyone(id: id)
    elsif params[:type] == "state"
      if current_user.state_code
        rankings = Ranking.for_state(state_code: current_user.state_code, id: id)
      end
    elsif params[:type] == "friends"
      rankings = Ranking.for_user_in_users_friend_list(user: current_user)
    end

    render json: rankings, include: ['user']
  end
end
