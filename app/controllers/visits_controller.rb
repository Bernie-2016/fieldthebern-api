require 'ground_game/scenario/create_visit'

class VisitsController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    result = GroundGame::Scenario::CreateVisit.new(visit_params, address, people, current_user).call
    if result.success?
      UpdateUsersLeaderboardsWorker.perform_async(result.visit.user.id)
      render json: result.visit, include: ['score']
    else
      render json: result.error.hash, status: result.error.status
    end
  end

  private

  def visit_params
    record_attributes.permit(:duration_sec)
  end

  def address
    address_params = included_records.select{ |record| record[:type] == "addresses" }.first
    address = address_params.fetch(:attributes, {}).permit(:best_canvas_response, :latitude, :longitude, :street_1, :street_2, :city, :state_code, :zip_code)
    address_id = address_params.fetch(:id, nil)
    address = address.merge(id: address_id) if address_id
    address
  end

  def people
    people = included_records.select{ |record| record[:type] == "people" }.map{ |person_params|
      params = ActionController::Parameters.new(person_params.fetch(:attributes, {}))
      person = params.permit(:first_name, :last_name, :email, :phone,
        :preferred_contact_method, :previously_participated_in_caucus_or_primary,
        :party_affiliation, :canvas_response)
      person_id  = person_params.fetch(:id, nil)
      person = person.merge(id: person_id) if person_id
      person
    }
  end

end
