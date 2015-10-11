require 'rails_helper'
require 'ground_game/scenario/create_visit'

module GroundGame
  module Scenario

    describe CreateVisit do

      describe "#call" do

        it 'computes and assigns the score'

        context 'when the address already exists' do
          context 'when the person already exists' do
            it 'creates a visit, updates the address, updates the person'
          end

          context 'when the person does not exist' do
            it 'creates a visit, updates the address and creates the person'
          end
        end

        context 'when the address doesn\'t exist' do
          it 'creates the visit, the address and the people'
        end
      end
    end
  end
end
