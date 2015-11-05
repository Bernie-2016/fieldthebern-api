require 'rails_helper'

describe Person do
  it "has a valid factory" do
    expect(build(:person)).to be_valid
  end

  context 'schema' do
    it { should have_db_column(:first_name).of_type(:string) }
    it { should have_db_column(:last_name).of_type(:string) }
    it { should have_db_column(:canvas_response).of_type(:string) }
    it { should have_db_column(:party_affiliation).of_type(:string) }
    it { should have_db_column(:address_id).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
    it { should have_db_column(:previously_participated_in_caucus_or_primary).of_type(:boolean).with_options(default: false) }
  end

  context 'associations' do
    it { should belong_to(:address) }
  end

  it "has a working canvas_response enum" do
    person = create(:person)

    expect(person.unknown?).to be true

    person.strongly_for!
    expect(person.strongly_for?).to be true

    person.leaning_for!
    expect(person.leaning_for?).to be true

    person.undecided!
    expect(person.undecided?).to be true

    person.leaning_against!
    expect(person.leaning_against?).to be true

    person.strongly_against!
    expect(person.strongly_against?).to be true

    person.asked_to_leave!
    expect(person.asked_to_leave?).to be true
  end

  it "has a working party_affiliation enum" do
    person = create(:person)

    expect(person.unknown_affiliation?).to be true

    person.democrat_affiliation!
    expect(person.democrat_affiliation?).to be true

    person.republican_affiliation!
    expect(person.republican_affiliation?).to be true

    person.undeclared_affiliation!
    expect(person.undeclared_affiliation?).to be true

    person.independent_affiliation!
    expect(person.independent_affiliation?).to be true
  end

  describe "instance methods" do
    describe "#more_supportive_than?" do
      it "works" do
        person = create(:person, canvas_response: :leaning_for)
        other_person_1 = create(:person, canvas_response: :undecided)
        other_person_2 = create(:person, canvas_response: :strongly_for)

        expect(person.more_supportive_than? other_person_1).to be true
        expect(person.more_supportive_than? other_person_2).to be false
      end
    end

    describe "#canvas_response_rating" do
      it "works" do
        person = create(:person)

        expect(person.canvas_response_rating).to eq 2

        person.strongly_for!
        expect(person.canvas_response_rating).to eq 5

        person.leaning_for!
        expect(person.canvas_response_rating).to eq 3

        person.undecided!
        expect(person.canvas_response_rating).to eq 2

        person.leaning_against!
        expect(person.canvas_response_rating).to eq 1

        person.strongly_against!
        expect(person.canvas_response_rating).to eq 0

        person.unknown!
        expect(person.canvas_response_rating).to eq 2

        person.asked_to_leave!
        expect(person.canvas_response_rating).to eq -1
      end
    end
  end


  describe ".new_or_existing_from_params" do
    it "initializes a new person if the params do not contain an id" do
      expect(Person.count).to eq 0
      params = {
        first_name: "John",
        last_name: "Doe",
        previously_participated_in_caucus_or_primary: true
      }
      person = Person.new_or_existing_from_params(params)
      expect(person.persisted?).to be false
      expect(person.previously_participated_in_caucus_or_primary?).to be true
    end
    it "fetches and updates (without save) an existing person if the params do contain an id" do
      create(:person,
        id: 1,
        first_name: "Jake",
        last_name: "Smith",
        previously_participated_in_caucus_or_primary: false)
      params = {
        id: 1,
        first_name: "John",
        last_name: "Doe",
        previously_participated_in_caucus_or_primary: true
      }
      person = Person.new_or_existing_from_params(params)
      expect(Person.count).to eq 1
      expect(person.changed?).to be true
      expect(person.first_name).to eq "John"
      expect(person.last_name).to eq "Doe"
      expect(person.previously_participated_in_caucus_or_primary?).to be true
    end
  end
end
