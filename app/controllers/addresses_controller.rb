class AddressesController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    addresses = Address.within(index_params[:latitude], index_params[:longitude], index_params[:radius])
    render json: addresses
  end

  def create
  end

  def index_params
    latitude = params.require(:latitude)
    longitude = params.require(:longitude)
    radius = params.require(:radius)
    return { latitude: latitude, longitude: longitude, radius: radius }
  end

end
