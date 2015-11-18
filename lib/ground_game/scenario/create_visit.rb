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

        # address

        def create_or_update_address(address_params, visit)
          address = fetch_or_initialize_address(address_params)

          address_params = GroundGame::EasyPostHelper.extend_address_params_with_usps(address_params) if address.new_record?

          raise GroundGame::VisitNotAllowed if address.recently_visited?

          address.assign_attributes(address_params)
          assign_address_best_canvas_response(address, address_params)
          assign_address_last_canvas_response(address, address_params)

          # AddressUpdate absolutely needs to be created after initializing/fetching
          # and updating, but before saving the address due to it needing access to
          # old and new address attribute values.
          AddressUpdate.create_for_visit_and_address(visit, address)

          address.save!
          address
        end

        def assign_address_best_canvas_response(address, params)
          new_value = params[:best_canvass_response]
          if new_value.present?
            new_value_is_valid = ["asked_to_leave", "not_yet_visited", "not_home"].include? new_value
            raise GroundGame::InvalidBestCanvassResponse.new(new_value) unless new_value_is_valid
            address.best_canvass_response = new_value
          elsif address.new_record?
            address.best_canvass_response = "not_home"
          end
        end

        def assign_address_last_canvas_response(address, params)
          address.last_canvass_response = params[:best_canvass_response] if params[:best_canvass_response].present?
          address.last_canvass_response = params[:last_canvass_response] if params[:last_canvass_response].present?
        end

        def fetch_or_initialize_address(address_params)
          address_id = address_params[:id]
          address = Address.new if address_id.nil?
          address = Address.find(address_id) if address_id.present?
          address
        end

        # people

        def create_or_update_people_for_address(people_params, address, visit)
          people_params.map do |person_params|
            create_or_update_person_for_address(person_params, address, visit)
          end
        end

        def create_or_update_person_for_address(person_params, address, visit)
          # We remove the nils from params since our client may not have some
          # values, e.g. phone or email; we want to allow API values to
          # remain unchanged in this event
          person_params = remove_nils_from_params(person_params)

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

        def remove_nils_from_params(params)
          params.compact
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
