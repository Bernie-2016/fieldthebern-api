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

        visit
      end

      def validate_params(params)
        # TODO: Does nothing at the moment
        # Should
        #   1. reverse geocode submitted coordinates
        #   2. validate and fill out address fields using UMTS directly (or via easypost)
        #   3. set corrected coordinates


        params[:corrected_longitude] = params[:submitted_longitude]
        params[:corrected_latitude] = params[:submitted_latitude]

        params
      end

      def inferr_address(params)
        # TODO: Extremely naive right now. We should probably
        #   1. inferr it first from coordinates
        #   2. if that doesn't work, try to find it from street fields somehow
        #   3. if that doesn't work, create it
        Address.find_or_initialize_by(longitude: params[:corrected_longitude], latitude: params[:corrected_latitude])
      end
    end
  end
end
