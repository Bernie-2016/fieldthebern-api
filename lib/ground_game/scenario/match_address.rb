require "ground_game/easypost_helper"

module GroundGame
  module Scenario
    class MatchAddress
      def initialize(address_params)
        @address_params = address_params
      end

      def call
        address, error_code, error_message = EasyPostHelper.create_and_verify_address(@address_params)

        if address
          query_hash = EasyPostHelper.easypost_address_to_usps_hash(address)
          matched_address = Address.where(query_hash)

          if !matched_address.empty?
            return true, 200, nil, matched_address
          else
            return false, 404, "No match for this address", nil
          end
        else
          return false, error_code, error_message, nil
        end
      end
    end
  end
end
