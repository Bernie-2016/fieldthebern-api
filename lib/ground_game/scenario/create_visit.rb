module GroundGame
  module Scenario
    class CreateVisit
      include Geokit::Geocoders

      def initialize(visit_params, included_record_params, current_user)
        @visit_params = visit_params
        @included_record_params = included_record_params
        @current_user = current_user
      end

      def call
        visit = Visit.new(@visit_params)
        visit.user = @current_user

        # TODO: Create or update address
        # TODO: Create or update each person

        address = create_or_update_address(@included_record_params[:address]) if @included_record_params[:address]
        visit.address = address

        people = create_or_update_people_for_address(@included_record_params[:people], address) if @included_record_params[:people]

        address.most_supportive_resident = people.max{ |person| rate_persons_support(person) }
        address.save!

        visit.total_points = CreateScore.new(visit: visit).call

        visit
      end

      private

      def create_or_update_address(address_params)
        address_attributes = address_params.fetch(:attributes, {})
        address_id = address_params.fetch(:id, nil)
        if address_id
          address = Address.find(address_id)
          address.update!(address_attributes)
        else
          address = Address.new(address_attributes)
          address.save!
        end

        address
      end

      def create_or_update_people_for_address(people_params, address)
        people = []
        people_params.each do |person_params|
          person_attributes = person_params.fetch(:attributes, {})
          person_id = person_params.fetch(:id, nil)
          if person_id
            person = Person.find(person_id)
            person.update!(person_attributes)
          else
            person = Person.new(person_attributes)
            person.address = address;
            person.save!
          end
          people.push(person)
        end
        people
      end

      def rate_persons_support(person)
        0 if person.strongly_against?
        1 if person.leaning_against?
        2 if person.undecided? or person.unknown?
        3 if person.leaning_for?
        4 if person.strongly_for?
      end
    end
  end
end
