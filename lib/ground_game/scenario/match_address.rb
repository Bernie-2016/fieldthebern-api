module GroundGame
  module Scenario
    class MatchAddress
      def initialize(address_params)
        @address_params = address_params
      end

      def call
        street1 = @address_params.fetch(:street_1, "")
        street2 = @address_params.fetch(:street_2, "")
        street_name = [street1, street2].reject(&:empty?).join(" ")

        begin
          address = EasyPost::Address.create_and_verify(
            :street1 => street_name,
            :city => @address_params.fetch(:city, nil),
            :state => @address_params.fetch(:state_code, nil),
            :zip => @address_params.fetch(:zip_code, nil)
          )

          matched_address = Address.where(
            usps_verified_street_1: address.street1,
            usps_verified_street_2: address.street2,
            usps_verified_city: address.city,
            usps_verified_state: address.state,
            usps_verified_zip: address.zip
          )

          if !matched_address.empty?
            return true, 200, nil, matched_address
          else
            return false, 404, "No match for this address", nil
          end

        rescue EasyPost::Error => e
          return false, e.http_status, e.message.strip, nil
        end
      end
    end
  end
end
