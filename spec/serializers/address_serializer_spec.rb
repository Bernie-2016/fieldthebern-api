require 'rails_helper'

describe AddressSerializer, :type => :serializer do

  context 'individual resource representation' do
    let(:resource) { build(:address) }

    let(:serializer) { AddressSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context 'root' do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it 'has an attributes object' do
        expect(subject['attributes']).not_to be nil
      end

      it 'has an id' do
        expect(subject['id']).not_to be nil
      end

      it 'has a type set to `addresses`' do
        expect(subject['type']).to eq 'addresses'
      end
    end

    context 'attributes' do

      subject do
        JSON.parse(serialization.to_json)["data"]['attributes']
      end


      it 'has a longitude' do
        expect(subject['longitude']).to eql(resource.longitude)
      end

      it 'has a latitude' do
        expect(subject['latitude']).to eql(resource.latitude)
      end

      it 'has a street_1' do
        expect(subject['street_1']).to eql(resource.street_1)
      end

      it 'has a street_2' do
        expect(subject['street_2']).to eql(resource.street_2)
      end

      it 'has a city' do
        expect(subject['city']).to eql(resource.city)
      end

      it 'has a state_code' do
        expect(subject['state_code']).to eql(resource.state_code)
      end

      it 'has a zip_code' do
        expect(subject['zip_code']).to eql(resource.zip_code)
      end

      it 'has a visited_at' do
        expect(subject['visited_at']).to eql(resource.visited_at)
      end

      it 'has a latest_result' do
        expect(subject['latest_result']).to eql(resource.latest_result)
      end
    end
  end
end
