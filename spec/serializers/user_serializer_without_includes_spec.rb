require "rails_helper"

describe UserSerializerWithoutIncludes, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { create(:user) }

    let(:serializer) { UserSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)['data']
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be nil
      end

      it "has an id" do
        expect(subject["id"]).to eq resource.id.to_s
      end

      it "has a type set to `users`" do
        expect(subject["type"]).to eq "users"
      end
    end

    context 'attributes' do
      subject do
        JSON.parse(serialization.to_json)['data']['attributes']
      end

      it 'has a first_name' do
        expect(subject['first_name']).to eq resource.first_name
      end

      it "has a last_name" do
        expect(subject["last_name"]).to eq resource.last_name
      end

      it "has an email" do
        expect(subject["email"]).to eq resource.email
      end

      it "has a state_code" do
        expect(subject["state_code"]).to eq resource.state_code
      end

      it 'has a thumbnail photo url' do
        expect(subject['photo_thumb_url']).to eq resource.photo.url(:thumb)
      end

      it 'has a large photo url' do
        expect(subject['photo_large_url']).to eq resource.photo.url(:large)
      end

      # BigDecimals are passed as strings
      it 'has a lat' do
        expect(subject['lat']).to eq resource.lat.to_s
      end

      it 'has a lng' do
        expect(subject['lng']).to eq resource.lng.to_s
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should include a 'visits' relationship" do
        expect(subject["visits"]).not_to be_nil
      end

      it "should include a 'following' relationship" do
        expect(subject["following"]).not_to be_nil
      end

      it "should include a 'followers' relationship" do
        expect(subject["followers"]).not_to be_nil
      end
    end

    context "included" do
      subject do
        JSON.parse(serialization.to_json)["included"]
      end

      it "should be empty" do
        expect(subject).to be_nil
      end
    end
  end
end
