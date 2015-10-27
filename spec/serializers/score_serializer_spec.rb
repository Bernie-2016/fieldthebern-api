require "rails_helper"

describe ScoreSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { build(:score, visit: build(:visit)) }

    let(:serializer) { ScoreSerializer.new(resource) }
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

      it "has a type set to 'scores'" do
        expect(subject["type"]).to eq "scores"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'points_for_updates'" do
        expect(subject["points_for_updates"]).to eql(resource.points_for_updates)
      end

      it "has a 'points_for_knock'" do
        expect(subject["points_for_knock"]).to eql(resource.points_for_knock)
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
