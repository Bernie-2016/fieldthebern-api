require 'ground_game/scenario/create_visit'
require 'ground_game/scenario/update_users_total_score'

class VisitsController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    visit = GroundGame::Scenario::CreateVisit.new(visit_params, address, people, current_user).call
    if visit.save
      GroundGame::Scenario::UpdateUsersTotalScore.new(visit.user).call
      render json: visit, include: ['score']
    else
      render_validation_errors visit.errors
    end
  end

  private

  def visit_params
    record_attributes.permit(:duration_sec)
  end

  def address
    address_params = included_records.select{ |record| record[:type] == "addresses" }.first
    address = address_params.fetch(:attributes, {}).permit(:latitude, :longitude, :street_1, :street_2, :city, :state_code, :zip_code)
    address_id = address_params.fetch(:id, nil)
    address = address.merge(id: address_id) if address_id
    address
  end

  def people
    people = included_records.select{ |record| record[:type] == "people" }.map{ |person_params|
      person = person_params.fetch(:attributes, {})
      person_id  = person_params.fetch(:id, nil)
      person = person.merge(id: person_id) if person_id
      person
    }
  end

end
