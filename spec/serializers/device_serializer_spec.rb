require "rails_helper"

describe DeviceSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { build(:device, user: build(:user)) }

    let(:serializer) { DeviceSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be nil
      end

      it "has an id" do
        expect(subject["id"]).not_to be nil
      end

      it "has a type set to 'devices'" do
        expect(subject["type"]).to eq "devices"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'token'" do
        expect(subject["token"]).to eql(resource.token)
      end

      it "has a 'platform'" do
        expect(subject["platform"]).to eql(resource.platform)
      end

      it "has an 'enabled'" do
        expect(subject["enabled"]).to eql(resource.enabled)
      end

    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should include a 'visit' relationship" do
        expect(subject["user"]).not_to be_nil
        expect(subject["user"]["data"]["id"]).to eq resource.user_id.to_s
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
