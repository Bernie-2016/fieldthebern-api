require "ground_game/easypost_helper"
require "ground_game/errors/address_unmatched"
require "ground_game/scenario/scenario_result"

module GroundGame
  module Scenario

    class MatchAddressResult < ScenarioResult
      def initialize(address: nil, error:nil)
        super(result: address, error: error)
      end

      def address
        @result
      end
    end

    class MatchAddress
      def initialize(address_params)
        @address_params = address_params
      end

      def call
        begin
          easypost_address = EasyPostHelper.create_and_verify_address!(@address_params)
          query = EasyPostHelper.easypost_address_to_usps_hash(easypost_address)
          address = Address.where(query).first
          raise GroundGame::AddressUnmatched if address.nil?
          MatchAddressResult.new(address: address)
        rescue EasyPost::Error, GroundGame::AddressUnmatched => e
          MatchAddressResult.new(error: e)
        end
      end
    end
  end
end
