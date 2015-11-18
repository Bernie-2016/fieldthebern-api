require 'rails_helper'

describe PersonSerializer, :type => :serializer do

  context 'individual resource representation' do
    let(:resource) {
      create(:person,
        first_name: "Josh",
        last_name: "Smith",
        party_affiliation: "Democrat",
        canvass_response: "strongly_for",
        previously_participated_in_caucus_or_primary: false,
        phone: "415-706-4899",
        email: "josh@coderly.com",
        preferred_contact_method: "phone"
      )
    }

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
        expect(subject['first_name']).to eql "Josh"
      end

      it 'has a last_name' do
        expect(subject['last_name']).to eql "Smith"
      end

      it 'has a canvass_response' do
        expect(subject['canvass_response']).to eql "strongly_for"
      end

      it 'has a party_affiliation' do
        expect(subject['party_affiliation']).to eql "democrat_affiliation"
      end

      it 'has a created_at' do
        expect(subject['created_at']).to_not be_nil
        expect(ActiveSupport::TimeZone['UTC'].parse(subject['created_at'])).to be_within(0.1).of(resource.created_at)
      end

      it 'has a updated_at' do
        expect(subject['updated_at']).to_not be_nil
        expect(ActiveSupport::TimeZone['UTC'].parse(subject['updated_at'])).to be_within(0.1).of(resource.updated_at)
      end

      it 'has a previously_participated_in_caucus_or_primary' do
        expect(subject['previously_participated_in_caucus_or_primary']).to eql false
      end

      it 'has a preferred_contact_method' do
        expect(subject['preferred_contact_method']).to eql "phone"
      end

      it 'should not expose phone' do
        expect(subject['phone']).to be_nil
      end

      it 'should not expose email' do
        expect(subject['email']).to be_nil
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
