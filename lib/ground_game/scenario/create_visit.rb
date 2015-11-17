require "ground_game/scenario/create_score"
require "ground_game/errors/visit_not_allowed"
require "ground_game/errors/invalid_best_canvass_response"
require "ground_game/scenario/scenario_result"

module GroundGame
  module Scenario
    class CreateVisitResult < ScenarioResult
      def initialize(visit: nil, error:nil)
        super(result: visit, error: error)
      end

      def visit
        @result
      end
    end

    class CreateVisit
      def initialize(visit_params, address_params, people_params, current_user)
        @visit_params = visit_params
        @address_params = address_params
        @people_params = people_params
        @current_user = current_user
      end

      def call
        begin
          Visit.transaction do
            visit = create_visit(@visit_params, @address_params, @people_params, @current_user)
            CreateVisitResult.new(visit: visit)
          end
        rescue ArgumentError, ActiveRecord::RecordNotFound, VisitNotAllowed, InvalidBestCanvassResponse => e
          CreateVisitResult.new(error: e)
        end
      end

      private

        def create_visit(visit_params, address_params, people_params, user)
          visit = Visit.new(visit_params)
          visit.user = user

          address = create_or_update_address(address_params, visit)
          address.visited_at = DateTime.now

          people = create_or_update_people_for_address(people_params, address, visit)

          address = update_most_supportive_resident(address, people)
          address.save!

          visit.total_points = CreateScore.new(visit).call.total_points
          visit.save!

          update_users_state_to_address_state(visit)

          visit
        end

        def create_or_update_address(address_params, visit)
          address = Address.new_or_existing_from_params(address_params)

          # In a regular case, the default for address.best_canvass_response is "not yet visited"
          # In the case of a visit, however, it makes more sense for the default to ne "not home"
          # Due to this, it makes more sense to set that default here, in the CreateVisit scenario
          # instead of at the model level.
          address.best_canvass_response = :not_home if address.new_record? and address_params[:best_canvass_response].nil?

          # I do not like that this is here, but I couldn't think of a better way.
          # AddressUpdate absolutely needs to be created after initializing/fetching
          # and updating, but before saving the address due to it needing access to
          # old and new address attributes.
          AddressUpdate.create_for_visit_and_address(visit, address)

          address.save!
          address
        end

        def create_or_update_people_for_address(people_params, address, visit)
          people_params.map do |person_params|
            create_or_update_person_for_address(person_params, address, visit)
          end
        end

        def create_or_update_person_for_address(person_params, address, visit)
          person = Person.new_or_existing_from_params(person_params)
          person.address = address

          # I do not like that this is here, but I couldn't think of a better way.
          # PersonUpdate absolutely needs to be created after initializing/fetching
          # and updating, but before saving the person due to it needing access to
          # old and new address attributes.
          PersonUpdate.create_for_visit_and_person(visit, person)

          person.save!
          person
        end

        def update_most_supportive_resident(address, people)
          most_supportive_resident = person_with_highest_rated_canvass_response(people)

          if most_supportive_resident
            address.assign_most_supportive_resident(most_supportive_resident)
            address.last_canvass_response = most_supportive_resident.canvass_response
          end

          address
        end

        def person_with_highest_rated_canvass_response(people)
          people.max_by(&:canvass_response_rating)
        end

        def update_users_state_to_address_state(visit)
          user = visit.user
          if visit.address && visit.address.state_code
            return if user.state_code == visit.address.state_code
            user.state_code = visit.address.state_code
            user.save!
          end
        end
    end
  end
end
