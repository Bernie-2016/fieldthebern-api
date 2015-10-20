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

        most_supportive_resident = person_with_highest_rated_canvas_response(people)
        if most_supportive_resident
          address.best_canvas_response = most_supportive_resident.canvas_response
          address.most_supportive_resident = most_supportive_resident
        elsif not address.most_supportive_resident
          address.best_canvas_response = :not_home
        end

        address.save!

        visit.total_points = CreateScore.new(visit: visit, number_of_updated_people: @people_params.count).call.total_points

        visit
      end

      private

      def person_with_highest_rated_canvas_response(people)
        people.max{ |person| person.canvas_response_rating }
      end

      def create_or_update_address(address_params, visit)
        address_id = address_params.fetch(:id, nil)

        if address_id
          address = Address.find(address_id)
          address_update = AddressUpdate.create(address: address, visit: visit, update_type: :modify)
          address.update!(address_params)
        else
          address = Address.create(address_params)
          address_update = AddressUpdate.create(address: address, visit: visit, update_type: :create)
        end

        address
      end

      def create_or_update_people_for_address(people_params, address, visit)
        people_params.map do |person_params|
          person_id = person_params.fetch(:id, nil)

          if person_id
            person = Person.find(person_id)

            PersonUpdate.create(
              person: person,
              visit: visit,
              old_canvas_response: person.canvas_response,
              old_party_affiliation: person.party_affiliation,
              new_canvas_response: person_params[:canvas_response],
              new_party_affiliation: person_params[:party_affiliation])

            person.update!(person_params)
          else
            person = Person.new(person_params.merge(address: address))

            PersonUpdate.create(
              person: person,
              visit: visit,
              new_canvas_response: person.canvas_response,
              new_party_affiliation: person.party_affiliation)

            person.save!
          end

          person
        end
      end
    end
  end
end
