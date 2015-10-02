class AddressesController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    render json: index_params
  end

  def create
  end

  def index_params
    lattitude = params.require(:lattitude)
    longitude = params.require(:longitude)
    radius = params.require(:radius)
    return { lattitude: lattitude, longitude: longitude, radius: radius }
  end

end
