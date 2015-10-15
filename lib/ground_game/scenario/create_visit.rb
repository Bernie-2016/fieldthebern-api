require "ground_game/scenario/create_score"

module GroundGame
  module Scenario
    class CreateVisit
      include Geokit::Geocoders

      def initialize(visit_params, address_params, people_params, current_user)
        @visit_params = visit_params
        @address_params = address_params
        @people_params = people_params
        @current_user = current_user
      end

      def call
        visit = Visit.new(@visit_params)
        visit.user = @current_user

        address = create_or_update_address(@address_params)
        visit.address = address

        people = create_or_update_people_for_address(@people_params, address)

        most_supportive_resident = people.max{ |person| rate_persons_support(person) }

        address.best_canvas_response = most_supportive_resident.canvas_response
        address.most_supportive_resident = most_supportive_resident
        address.save!

        visit.total_points = CreateScore.new(visit: visit).call

        visit
      end

      private

      def create_or_update_address(address_params)
        address_id = address_params.fetch(:id, nil)
        if address_id
          address = Address.find(address_id)
          address.update!(address_params)
        else
          address = Address.new(address_params)
          address.save!
        end

        address
      end

      def create_or_update_people_for_address(people_params, address)
        people = []
        people_params.each do |person_params|
          person_id = person_params.fetch(:id, nil)
          if person_id
            person = Person.find(person_id)
            person.update!(person_params)
          else
            person = Person.new(person_params)
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
