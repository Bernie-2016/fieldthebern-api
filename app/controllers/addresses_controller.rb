class AddressesController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    addresses = Address.within(index_params[:radius], origin: [index_params[:latitude], index_params[:longitude]])
    render json: addresses
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

  def update_params
    params.permit(:id).merge(update_params)
  end
end
