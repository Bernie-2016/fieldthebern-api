require 'rails_helper'

describe PersonUpdate do
  it "has a valid factory" do
    expect(build(:person_update)).to be_valid
  end

  context 'schema' do
    it {should have_db_column(:person_id).of_type(:integer) }
    it {should have_db_column(:visit_id).of_type(:integer) }
    it {should have_db_column(:update_type).of_type(:string).with_options(default: 'created') }
  end

  context 'associations' do
    it { should belong_to(:person) }
    it { should belong_to(:visit) }
  end

  context 'validations' do
    it { should validate_presence_of(:person) }
    it { should validate_presence_of(:visit) }
    it { should validate_presence_of(:new_canvas_response) }
    it { should validate_presence_of(:new_party_affiliation) }
    it { should_not validate_presence_of(:old_canvas_response) }
    it { should_not validate_presence_of(:old_party_affiliation) }
  end

  it "has a working 'update_type' enum" do
    person_update = create(:person_update)

    expect(person_update.created?).to be true

    person_update.modified!
    expect(person_update.modified?).to be true

    person_update.created!
    expect(person_update.created?).to be true
  end

  describe ".create_for_visit_and_person" do
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
