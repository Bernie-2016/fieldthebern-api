require "ground_game/scenario/create_score"

module GroundGame
  module Scenario
    class CreateVisit
      def initialize(visit_params, address_params, people_params, current_user)
        @visit_params = visit_params
        @address_params = address_params
        @people_params = people_params
        @current_user = current_user
      end

      def call
        visit = Visit.new(@visit_params)
        visit.user = @current_user

        address = create_or_update_address(@address_params, visit)
        people = create_or_update_people_for_address(@people_params, address, visit)

        address = update_most_supportive_resident(address, people)
        address.save!

        visit.total_points = CreateScore.new(visit).call.total_points
        visit
      end

      private

      def create_or_update_address(address_params, visit)
        address = Address.new_or_existing_from_params(address_params)
        address.save!

        AddressUpdate.create_for_visit_and_address(visit, address)

        address
      end

      def create_or_update_people_for_address(people_params, address, visit)
        people_params.map do |person_params|
          person = Person.new_or_existing_from_params(person_params)
          person.address = address
          person.save!

          PersonUpdate.create_for_visit_and_person(visit, person)

          person
        end
      end

      def update_most_supportive_resident(address, people)
        most_supportive_resident = person_with_highest_rated_canvas_response(people)
        if most_supportive_resident
          address.best_canvas_response = most_supportive_resident.canvas_response
          address.most_supportive_resident = most_supportive_resident
        elsif not address.most_supportive_resident
          address.best_canvas_response = :not_home
        end

        address
      end

      def person_with_highest_rated_canvas_response(people)
        people.max{ |person| person.canvas_response_rating }
      end
    end
  end
end
