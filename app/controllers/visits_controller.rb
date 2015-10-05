class VisitsController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
  end

  private

  def create_params
  end
end
