class PingController < ApplicationController

  def index
    json = {"ping" => "pong"}
    render json: json
  end

end
