require "rails_helper"

describe RankingSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { build(:ranking, member: create(:user, id: 20).id) }

    let(:serializer) { RankingSerializer.new(resource) }
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

      it "has a type set to 'rankings'" do
        expect(subject["type"]).to eq "rankings"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'score'" do
        expect(subject["score"]).to eql(resource.score)
      end

      it "has a 'rank'" do
        expect(subject["rank"]).to eql(resource.rank)
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should include a 'user' relationship" do
        expect(subject["user"]).not_to be_nil
        expect(subject["user"]["data"]["id"]).to eq resource.user_id.to_s
      end
    end

    context "included" do
      context "when including" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["user"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).to_not be_nil
          expect(subject.first["id"]).to eq "20"
          expect(subject.first["type"]).to eq "users"
        end
      end

      context "when not including" do
        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should be empty" do
          expect(subject).to be_nil
        end
      end
    end
  end
end
