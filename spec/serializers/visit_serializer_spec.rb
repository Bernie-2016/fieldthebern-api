require "rails_helper"

describe VisitSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { create(:visit) }

    let(:serializer) { VisitSerializer.new(resource) }
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

      it "has a type set to `visits`" do
        expect(subject["type"]).to eq "visits"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a created_at" do
        expect(subject["created_at"]).not_to be nil
      end

      it "has a total_points" do
        expect(subject["total_points"]).to eql(resource.total_points)
      end

      it "has a duration_sec" do
        expect(subject["duration_sec"]).to eql(resource.duration_sec)
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should include a 'user' relationship" do
        expect(subject["user"]).not_to be_nil
        expect(subject["user"]["data"]["id"]).to eq resource.user.id.to_s
        expect(subject["user"]["data"]["type"]).to eq "users"
      end

      it "should include an 'address_update' relationship" do
        expect(subject["address_update"]).not_to be_nil
        expect(subject["address_update"]["data"]["id"]).to eq resource.address_update.id.to_s
        expect(subject["address_update"]["data"]["type"]).to eq "address_updates"
      end

      it "should include an 'address' relationship" do
        expect(subject["address"]).not_to be_nil
        expect(subject["address"]["data"]["id"]).to eq resource.address_update.address.id.to_s
        expect(subject["address"]["data"]["type"]).to eq "addresses"
      end

      it "should include a 'person_updates' relationship" do
        expect(subject["person_updates"]).not_to be_nil
        expect(subject["person_updates"]["data"].length).to eq 2
        expect(subject["person_updates"]["data"][0]["type"]).to eq "person_updates"
      end

      it "should include a 'people' relationship" do
        expect(subject["people"]).not_to be_nil
        expect(subject["people"]["data"].length).to eq 2
        expect(subject["people"]["data"][0]["type"]).to eq "people"
      end

      it "should include a 'score' relationship" do
        expect(subject["score"]).not_to be_nil
        expect(subject["score"]["data"]["id"]).to eq resource.score.id.to_s
        expect(subject["score"]["data"]["type"]).to eq "scores"
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
