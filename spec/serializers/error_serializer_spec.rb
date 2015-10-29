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

    it "can serialize GroundGame::AddressUnmatched error" do
      address_unmatched_error = GroundGame::AddressUnmatched.new
      result = ErrorSerializer.serialize(address_unmatched_error)
      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "ADDRESS_UNMATCHED"
      expect(error[:title]).to eq "Address unmatched"
      expect(error[:detail]).to eq "The requested address does not exist in the database."
      expect(error[:status]).to eq 404
    end

    it "can serialize EasyPost::Error" do
      easypost_error = EasyPost::Error.new("A message", 400)
      result = ErrorSerializer.serialize(easypost_error)
      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "EASYPOST_ERROR"
      expect(error[:title]).to eq "Easypost error"
      expect(error[:detail]).to eq "A message"
      expect(error[:status]).to eq 400
    end
  end
end
