require "rails_helper"

describe ErrorSerializer do
  describe  ".serialize" do
    it "can serialize ArgumentError" do
      argument_error = ArgumentError.new("A message")
      result = ErrorSerializer.serialize(argument_error)
      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "ARGUMENT_ERROR"
      expect(error[:title]).to eq "Argument error"
      expect(error[:detail]).to eq "A message"
      expect(error[:status]).to eq 422
    end

    it "can serialize ActiveRecord::RecordNotFound error" do
      record_not_found_error = ActiveRecord::RecordNotFound.new("A message")
      result = ErrorSerializer.serialize(record_not_found_error)
      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "RECORD_NOT_FOUND"
      expect(error[:title]).to eq "Record not found"
      expect(error[:detail]).to eq "A message"
      expect(error[:status]).to eq 404
    end

    it "can serialize GroundGame::VisitNotAllowed error" do
      require "ground_game/errors/visit_not_allowed"
      visit_not_allowed_error = GroundGame::VisitNotAllowed.new
      result = ErrorSerializer.serialize(visit_not_allowed_error)
      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "VISIT_NOT_ALLOWED"
      expect(error[:title]).to eq "Visit not allowed"
      expect(error[:detail]).to eq "You cannot visit this address so soon since it was last visited"
      expect(error[:status]).to eq 403
    end
  end
end
