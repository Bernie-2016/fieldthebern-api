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

      it 'has a created_at' do
        expect(subject['created_at']).to eql(resource.created_at)
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
        expect(subject['user']['data']['type']).to eq 'users'
      end

      it 'should include an address relationship' do
        expect(subject['address']).not_to be_nil
        expect(subject['address']['data']['id']).to eq resource.address_id.to_s
        expect(subject['address']['data']['type']).to eq 'addresses'
      end

      it 'should include a people relationship' do
        expect(subject['people']).not_to be_nil
        expect(subject['people']['data'][0]['id']).to eq resource.people.first.id.to_s
        expect(subject['people']['data'][0]['type']).to eq 'people'
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
