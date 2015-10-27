require "rails_helper"

describe PersonUpdateSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { build(:person_update, visit: build(:visit), person: build(:person)) }

    let(:serializer) { PersonUpdateSerializer.new(resource) }
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

      it "has a type set to 'person_updates'" do
        expect(subject["type"]).to eq "person_updates"
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

      it "should include a 'person' relationship" do
        expect(subject["person"]).not_to be_nil
        expect(subject["person"]["data"]["id"]).to eq resource.person_id.to_s
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
