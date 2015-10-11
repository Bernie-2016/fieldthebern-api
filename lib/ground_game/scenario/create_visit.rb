module GroundGame
  module Scenario
    class CreateVisit
      include Geokit::Geocoders

      def initialize(params, current_user)
        @params = params
        @current_user = current_user
      end

      def call
        visit = Visit.new(@params)
        visit.user = @current_user

        # TODO: Create or update address
        # TODO: Create or update each person

        address = update_address(@params[:address_attributes]) if @params[:address_id]
        address = create_address(@params[:address_attributes]) unless @params[:address_id]

        address.visited_at = Time.now
        address.save!

        visit.address = address

        visit.total_points = CreateScore.new(visit: visit).call

        visit
      end

      def create_address(address_params)
        address = Address.new(address_params)
      end

      def update_address(address_params)
        address = Address.find(address_params[:id]).update(address_params)
      end
    end
  end
end
