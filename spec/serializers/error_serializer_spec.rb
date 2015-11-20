require "rails_helper"
require "ground_game/errors/address_unmatched"
require "ground_game/errors/visit_not_allowed"

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
      visit_not_allowed_error = GroundGame::VisitNotAllowed.new
      result = ErrorSerializer.serialize(visit_not_allowed_error)
      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "VISIT_NOT_ALLOWED"
      expect(error[:title]).to eq "Visit not allowed"
      expect(error[:detail]).to eq "You can't submit the same address so quickly after it was last visited."
      expect(error[:status]).to eq 403
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

    it "can serialize GroundGame::InvalidBestCanvassResponse error" do
      invalid_best_canvass_response_error = GroundGame::InvalidBestCanvassResponse.new("value")
      result = ErrorSerializer.serialize(invalid_best_canvass_response_error)
      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "INVALID_BEST_CANVASS_RESPONSE"
      expect(error[:title]).to eq "Invalid best canvass response"
      expect(error[:detail]).to eq "Invalid argument 'value' for address.best_canvass_response"
      expect(error[:status]).to eq 422
    end

    it "can serialize EasyPost::Error" do
      easypost_error = EasyPost::Error.new("A message", 400, nil, { error: { code: "A.CODE"}})
      result = ErrorSerializer.serialize(easypost_error)

      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "EASYPOST_ERROR_A_CODE"
      expect(error[:title]).to eq "Easypost: A code"
      expect(error[:detail]).to eq "A message"
      expect(error[:status]).to eq 400
    end


    it "can serialize Koala::Facebook::AuthenticationError" do
      facebook_authentication_error = Koala::Facebook::AuthenticationError.new(400, nil, { "message" => "A message" })
      result = ErrorSerializer.serialize(facebook_authentication_error)

      expect(result[:errors]).not_to be_nil
      expect(result[:errors].length).to eq 1

      error = result[:errors].first
      expect(error[:id]).to eq "FACEBOOK_AUTHENTICATION_ERROR"
      expect(error[:title]).to eq "Facebook authentication error"
      expect(error[:detail]).to eq "A message"
      expect(error[:status]).to eq 400
    end
  end
end
