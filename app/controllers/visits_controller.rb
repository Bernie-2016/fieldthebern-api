require 'ground_game/scenario/create_visit'

class VisitsController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    visit = GroundGame::Scenario::CreateVisit.new(create_params, include_params, current_user).call

    if visit.save
      render json: visit
    else
      render_validation_errors visit.errors
    end
  end

  private

  def create_params
    record_attributes.permit(:duration_sec)
  end

  def include_params
    {address: address, people: people}
  end

  def address
    included_records.select{ |record| record[:type] == "addresses" }.first
  end

  def people
    included_records.select{ |record| record[:type] == "people" }
  end

end
