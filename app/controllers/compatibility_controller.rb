class CompatibilityController < ApplicationController

  def show
    render json: { compatible: compatible? }
  end

  def app_version
    Gem::Version.new(params[:version])
  end

  def min_app_version
    Gem::Version.new(ENV["MIN_COMPATIBLE_APP_VERSION"])
  end

  def compatible?
    app_version >= min_app_version
  end

end
