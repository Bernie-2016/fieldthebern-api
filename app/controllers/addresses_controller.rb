require 'ground_game/scenario/match_address'

class AddressesController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    if params[:radius]
      match_addresses_using_radius
    else
      match_address_using_search_parameters
    end
  end

  private

    def match_addresses_using_radius
      addresses = Address.within(
          index_params[:radius],
          origin: [index_params[:latitude], index_params[:longitude]]
        ).
        includes([
          :most_supportive_resident,
          :people,
          :last_visited_by
        ])
      render json: addresses, include: ['last_visited_by']
    end

    def match_address_using_search_parameters
      result = GroundGame::Scenario::MatchAddress.new(search_params).call
      if result.success?
        render json: [result.address], include: ['people', 'last_visited_by']
      else
        render json: result.error.hash, status: result.error.status
      end
    end

    def index_params
      latitude = params.require(:latitude)
      longitude = params.require(:longitude)
      radius = params.require(:radius)
      { latitude: latitude, longitude: longitude, radius: radius }
    end

    def search_params
      params.permit(:latitude, :longitude, :street_1, :street_2, :city, :state_code, :zip_code)
    end
end
