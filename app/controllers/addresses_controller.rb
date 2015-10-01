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
    return { lattitude: lattitude, longitude: longitude }
  end

end
