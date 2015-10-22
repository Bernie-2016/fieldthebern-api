require 'rails_helper'

describe PersonUpdate do
  it "has a valid factory" do
    expect(build(:person_update)).to be_valid
  end

  it "requires a 'person'" do
    expect(build(:person_update, person: nil)).not_to be_valid
  end

  it "requires a 'visit'" do
    expect(build(:person_update, visit: nil)).not_to be_valid
  end

  it "requires a 'new_canvas_response'" do
    expect(build(:person_update, new_canvas_response: nil)).not_to be_valid
  end
  it "requires a 'new_party_affiliation'" do
    expect(build(:person_update, new_party_affiliation: nil)).not_to be_valid
  end

  it "does not require an 'old_canvas_response'" do
    expect(build(:person_update, old_canvas_response: nil)).to be_valid
  end
  it "does not require an 'old_party_affiliation'" do
    expect(build(:person_update, old_party_affiliation: nil)).to be_valid
  end

  it "has a working 'update_type' enum" do
    person_update = create(:person_update)

    expect(person_update.created?).to be true

    person_update.modified!
    expect(person_update.modified?).to be true

    person_update.created!
    expect(person_update.created?).to be true
  end

  context "#create_for_visit_and_person" do
    it "creates an update with 'created' type if person is a new record" do
      visit = create(:visit)
      person = build(:person)
      person_update = PersonUpdate.create_for_visit_and_person(visit, person)
      expect(person_update.created?).to be true
    end

    it "creates an update with 'modified' type if person is an existing record" do
      visit = create(:visit)
      person = create(:person)
      person_update = PersonUpdate.create_for_visit_and_person(visit, person)
      expect(person_update.modified?).to be true
    end
  end
end
