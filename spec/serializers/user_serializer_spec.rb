require "rails_helper"

describe UserSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { build(:user, id: 20, first_name: "John", last_name: "Doe", email: "john.doe@mail.com", state_code: "NY") }

    let(:serializer) { UserSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be nil
      end

      it "has an id" do
        expect(subject["id"]).to eq 20.to_s
      end

      it "has a type set to `users`" do
        expect(subject["type"]).to eq "users"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end


      it "has a first_name" do
        expect(subject["first_name"]).to eq "John"
      end

      it "has a last_name" do
        expect(subject["last_name"]).to eq "Doe"
      end

      it "has an email" do
        expect(subject["email"]).to eq "john.doe@mail.com"
      end

      it "has a state_code" do
        expect(subject["state_code"]).to eq "NY"
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
