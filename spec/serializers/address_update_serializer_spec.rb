require "rails_helper"

describe AddressUpdateSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { build(:address_update, visit: build(:visit), address: build(:address)) }

    let(:serializer) { AddressUpdateSerializer.new(resource) }
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

      it "has a type set to 'address_updates'" do
        expect(subject["type"]).to eq "address_updates"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'update_type'" do
        expect(subject["update_type"]).to eql(resource.update_type)
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should include a 'visit' relationship" do
        expect(subject["visit"]).not_to be_nil
        expect(subject["visit"]["data"]["id"]).to eq resource.visit_id.to_s
      end

      it "should include a 'address' relationship" do
        expect(subject["address"]).not_to be_nil
        expect(subject["address"]["data"]["id"]).to eq resource.address_id.to_s
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
