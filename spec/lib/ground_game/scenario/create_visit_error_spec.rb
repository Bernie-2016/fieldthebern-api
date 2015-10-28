require "rails_helper"
require "ground_game/scenario/create_visit"

module GroundGame
  module Scenario

    describe CreateVisitError do
      before do
        @argument_error = ArgumentError.new("A message")
        @record_not_found_error = ActiveRecord::RecordNotFound.new("A message")
      end
      it "maps .id based on error class" do
        expect(CreateVisitError.new(@argument_error).id).to eq "ARGUMENT_ERROR"
        expect(CreateVisitError.new(@record_not_found_error).id).to eq "RECORD_NOT_FOUND"
      end
      it "maps .title based on error class" do
        expect(CreateVisitError.new(@argument_error).title).to eq "Argument error"
        expect(CreateVisitError.new(@record_not_found_error).title).to eq "Record not found"
      end
      it "maps .detail to error message" do
        expect(CreateVisitError.new(@argument_error).detail).to eq "A message"
        expect(CreateVisitError.new(@record_not_found_error).detail).to eq "A message"
      end
      it "maps .status based on error class" do
        expect(CreateVisitError.new(@argument_error).status).to eq 422
        expect(CreateVisitError.new(@record_not_found_error).status).to eq 404
      end
      it "keeps a serialized hash of the error" do
        expect(CreateVisitError.new(@argument_error).hash).to eq ErrorSerializer.serialize(@argument_error)

        expect(CreateVisitError.new(@record_not_found_error).hash).to eq ErrorSerializer.serialize(@record_not_found_error)
      end
    end
  end
end
