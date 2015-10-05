require 'ground_game/scenario/create_visit'

class VisitsController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    visit = GroundGame::Scenario::CreateVisit.new(create_params, current_user).call

    if visit.save
      render json: visit
    else
      render_validation_errors visit.errors
    end
  end

  private

  def create_params
    record_attributes.permit(:submitted_latitude, :submitted_longitude, :submitted_street_1, :submitted_street_2,
      :submitted_city, :submitted_state_code, :submitted_zip_code, :result, :duration_sec)
  end

end
