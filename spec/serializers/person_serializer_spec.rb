require 'rails_helper'

describe PersonSerializer, :type => :serializer do

  context 'individual resource representation' do
    let(:resource) { build(:person) }

    let(:serializer) { PersonSerializer.new(resource) }
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

      it 'has a type set to `people`' do
        expect(subject['type']).to eq 'people'
      end
    end

    context 'attributes' do

      subject do
        JSON.parse(serialization.to_json)["data"]['attributes']
      end

      it 'has a first_name'
      it 'has a last_name'
      it 'has a canvas_response'
      it 'has a party_affiliation'
      it 'has a created_at'
      it 'has an updated_at'
    end

    context 'relationships' do
      subject do
        JSON.parse(serialization.to_json)['data']['relationships']
      end

      it 'should include an address relationship' do
        expect(subject['address']).not_to be_nil
        expect(subject['address']['data']['id']).to eq resource.address_id.to_s
      end
    end

    context 'includes' do
      subject do
        JSON.parse(serialization.to_json)["data"]['includes']
      end

      it 'should be empty' do
        expect(subject).to be_nil
      end
    end
  end
end
