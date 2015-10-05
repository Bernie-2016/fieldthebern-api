module GroundGame
  module Scenario
    class CreateVisit
      def initialize(params, current_user)
        @params = validate_params(params)
        @current_user = current_user
      end

      def call
        visit = Visit.new(@params)
        visit.user = @current_user

        address = inferr_address(@params)
        address.result = visit.result
        address.save!

        visit.address = address

        visit.total_points = CreateScore.new(visit: visit).call

        visit
      end

      def validate_params(params)
        params = validate_coords(params)
        params
      end

      def validate_coords(params)
        # This part should be replaced by reverse geocoded coordinates
        params[:corrected_longitude] = params[:submitted_longitude]
        params[:corrected_latitude] = params[:submitted_latitude]
        params
      end

      def inferr_address(params)
        # TODO: This is subject to change. Right now it,
        #   1. Tries to fetch via coordinates
        #   2. Tries to fetch via address
        #   3. Creates a new address if all else fails
        address = Address.find_by(longitude: params[:corrected_longitude], latitude: params[:corrected_latitude])
        address = Address.find_or_initialize_by(street_1: params[:submitted_street_1]) unless address
        address
      end
    end
  end
end
