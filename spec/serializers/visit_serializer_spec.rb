require 'rails_helper'

describe VisitSerializer, :type => :serializer do

  context 'individual resource representation' do
    let(:resource) { build(:visit) }

    let(:serializer) { VisitSerializer.new(resource) }
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

      it 'has a type set to `visits`' do
        expect(subject['type']).to eq 'visits'
      end
    end

    context 'attributes' do

      subject do
        JSON.parse(serialization.to_json)["data"]['attributes']
      end


      it 'has a submitted_longitude' do
        expect(subject['submitted_longitude']).to eql(resource.submitted_longitude)
      end

      it 'has a submitted_latitude' do
        expect(subject['submitted_latitude']).to eql(resource.submitted_latitude)
      end

      it 'has a corrected_longitude' do
        expect(subject['corrected_longitude']).to eql(resource.corrected_longitude)
      end

      it 'has a corrected_latitude' do
        expect(subject['corrected_latitude']).to eql(resource.corrected_latitude)
      end

      it 'has a sumbitted_street_1' do
        expect(subject['submitted_street_1']).to eql(resource.submitted_street_1)
      end

      it 'has a submitted_street_2' do
        expect(subject['submitted_street_2']).to eql(resource.submitted_street_2)
      end

      it 'has a submitted_city' do
        expect(subject['submitted_city']).to eql(resource.submitted_city)
      end

      it 'has a submitted_state_code' do
        expect(subject['submitted_state_code']).to eql(resource.submitted_state_code)
      end

      it 'has a submitted_zip_code' do
        expect(subject['submitted_zip_code']).to eql(resource.submitted_zip_code)
      end

      it 'has a created_at' do
        expect(subject['created_at']).to eql(resource.created_at)
      end

      it 'has a result' do
        expect(subject['result']).to eql(resource.result)
      end

      it 'has a total_points' do
        expect(subject['total_points']).to eql(resource.total_points)
      end

      it 'has a duration_sec' do
        expect(subject['duration_sec']).to eql(resource.duration_sec)
      end
    end

    context 'relationships' do
      subject do
        JSON.parse(serialization.to_json)['data']['relationships']
      end

      it 'should include a user relationship' do
        expect(subject['user']).not_to be_nil
        expect(subject['user']['data']['id']).to eq resource.user_id.to_s
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
