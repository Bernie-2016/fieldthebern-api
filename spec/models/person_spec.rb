require 'rails_helper'

describe Person do
  it "has a valid factory" do
    expect(build(:person)).to be_valid
  end

  it "has a working party_affiliation enum" do
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
  end

  it "has a working canvas_response enum" do
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
end
