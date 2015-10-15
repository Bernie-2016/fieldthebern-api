require 'ground_game/scenario/match_address'

class AddressesController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    if params[:radius]
      addresses = Address.within(index_params[:radius], origin: [index_params[:latitude], index_params[:longitude]])
      render json: addresses
    else
      success, status_code, message, matched_address = GroundGame::Scenario::MatchAddress.new(search_params).call

      case status_code
      when 200
        render json: matched_address, include: ['people'], status: status_code
      when 404
        render json: matched_address, status: status_code
      when 400
        render json: matched_address, status: status_code
      end
    end
  end

  def create
    address = Address.new(create_params)

    if address.save
      render json: address
    else
      render_validation_errors address.errors
    end
  end

  def index_params
    latitude = params.require(:latitude)
    longitude = params.require(:longitude)
    radius = params.require(:radius)
    { latitude: latitude, longitude: longitude, radius: radius }
  end

  def create_params
    params.permit(:latitude, :longitude, :street_1, :street_2, :city, :state_code, :zip_code, :visited_at)
  end

  def search_params
    params.permit(:latitude, :longitude, :street_1, :street_2, :city, :state_code, :zip_code)
  end

  def update_params
    params.permit(:id).merge(update_params)
  end
end
