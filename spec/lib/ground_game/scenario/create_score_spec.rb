require 'rails_helper'
require 'ground_game/scenario/create_score'

module GroundGame
  module Scenario

    describe CreateScore do

      describe "#call" do
        context 'when passing in a visit' do
          it 'computes score based on duration when result is :interested' do
            visit = create(:visit, result: :interested, duration_sec: 130 )
            score = CreateScore.new(visit: visit).call

            expect(score).to eq 470
          end

          it 'limits duration to 600 seconds' do
            visit = create(:visit, result: :interested, duration_sec: 700 )
            score = CreateScore.new(visit: visit).call

            expect(score).to eq 0
          end

          it 'only scores results set to :interested' do
            visit = create(:visit, result: :unsure, duration_sec: 20 )
            score = CreateScore.new(visit: visit).call

            expect(score).to eq 0
          end
        end
      end
    end
  end
end
