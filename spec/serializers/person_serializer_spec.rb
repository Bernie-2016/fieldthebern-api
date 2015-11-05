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

      it 'has a first_name' do
        expect(subject['first_name']).to eql(resource.first_name)
      end

      it 'has a last_name' do
        expect(subject['last_name']).to eql(resource.last_name)
      end

      it 'has a canvas_response' do
        expect(subject['canvas_response']).to eql(resource.canvas_response)
      end

      it 'has a party_affiliation' do
        expect(subject['party_affiliation']).to eql(resource.party_affiliation)
      end

      it 'has a created_at' do
        expect(subject['created_at']).to eql(resource.created_at)
      end

      it 'has a updated_at' do
        expect(subject['updated_at']).to eql(resource.updated_at)
      end

      it 'has a phone' do
        expect(subject['phone'].to eql(resource.phone))
      end

      it 'has an email' do
        expect(subject['email'].to eql(resource.email))
      end

      it 'has a preferred_contact_method' do
        expect(subject['preferred_contact_method'].to eql(resource.preferred_contact_method))
      end
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

    context "included" do
      subject do
        JSON.parse(serialization.to_json)["included"]
      end

      it 'should be empty' do
        expect(subject).to be_nil
      end
    end
  end
end
