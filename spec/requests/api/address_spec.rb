require 'rails_helper'

describe 'Address API' do
  describe 'POST /address' do
    it 'requires authentication' do
      post "#{host}/addresses"
      expect(last_response.status).to eq 401
    end
  end

  describe 'GET /address' do
    it 'requires authentication' do
      get "#{host}/addresses"
      expect(last_response.status).to eq 401
    end
  end
end
