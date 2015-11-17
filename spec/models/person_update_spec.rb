require 'rails_helper'

describe PersonUpdate do
  let(:visit) { build(:visit) }

  it "has a valid factory" do
    expect(build(:person_update, visit: visit)).to be_valid
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
    it { should validate_presence_of(:new_first_name) }
    it { should validate_presence_of(:new_canvass_response) }
    it { should validate_presence_of(:new_party_affiliation) }

    it { should_not validate_presence_of(:new_last_name) }
    it { should_not validate_presence_of(:new_address_id) }
    it { should_not validate_presence_of(:new_email) }
    it { should_not validate_presence_of(:new_phone) }
    it { should_not validate_presence_of(:new_preferred_contact_method) }
    it { should_not validate_presence_of(:new_previously_participated_in_caucus_or_primary) }
    it { should_not validate_presence_of(:old_canvass_response) }
    it { should_not validate_presence_of(:old_party_affiliation) }
  end

  it "has a working 'update_type' enum" do
    person_update = create(:person_update, visit: visit)

    expect(person_update.created?).to be true

    person_update.modified!
    expect(person_update.modified?).to be true

    person_update.created!
    expect(person_update.created?).to be true
  end

  describe ".create_for_visit_and_person" do
    it "creates an update with 'created' type if person is a new record" do
      visit = create(:visit)
      person = build(:person,
        first_name: "John",
        last_name: "Doe",
        canvass_response: :strongly_for,
        party_affiliation: :democrat_affiliation,
        phone: "555-555-1212",
        preferred_contact_method: "email",
        previously_participated_in_caucus_or_primary: true
      )
      person_update = PersonUpdate.create_for_visit_and_person(visit, person)
      expect(person_update.created?).to be true

      expect(person_update.old_first_name).to be_nil
      expect(person_update.old_last_name).to be_nil
      expect(person_update.old_canvass_response).to eq "unknown"
      expect(person_update.old_party_affiliation).to eq "unknown_affiliation"
      expect(person_update.old_phone).to be_nil
      expect(person_update.old_preferred_contact_method).to eq "contact_by_email"
      expect(person_update.old_previously_participated_in_caucus_or_primary).to eq false

      expect(person_update.new_first_name).to eq "John"
      expect(person_update.new_last_name).to eq "Doe"
      expect(person_update.new_canvass_response).to eq "strongly_for"
      expect(person_update.new_party_affiliation).to eq "democrat_affiliation"
      expect(person_update.new_phone).to eq "555-555-1212"
      expect(person_update.new_preferred_contact_method).to eq "contact_by_email"
      expect(person_update.new_previously_participated_in_caucus_or_primary).to eq true
    end

    it "creates an update with 'modified' type if person is an existing record" do
      visit = create(:visit)
      person = create(:person,
        first_name: "John",
        last_name: "Doe",
        canvass_response: :strongly_for,
        party_affiliation: :democrat_affiliation,
        phone: "555-555-1212",
        preferred_contact_method: "email",
        previously_participated_in_caucus_or_primary: true
      )

      person.first_name = "Josh"
      person.last_name = "Smith"
      person.canvass_response = :strongly_against
      person.party_affiliation = :republican_affiliation
      person.phone = "123-456-7890"
      person.preferred_contact_method = "phone"
      person.previously_participated_in_caucus_or_primary = false

      person_update = PersonUpdate.create_for_visit_and_person(visit, person)
      expect(person_update.modified?).to be true

      expect(person_update.old_first_name).to eq "John"
      expect(person_update.old_last_name).to eq "Doe"
      expect(person_update.old_canvass_response).to eq "strongly_for"
      expect(person_update.old_party_affiliation).to eq "democrat_affiliation"
      expect(person_update.old_phone).to eq "555-555-1212"
      expect(person_update.old_preferred_contact_method).to eq "contact_by_email"
      expect(person_update.old_previously_participated_in_caucus_or_primary).to eq true

      expect(person_update.new_first_name).to eq "Josh"
      expect(person_update.new_last_name).to eq "Smith"
      expect(person_update.new_canvass_response).to eq "strongly_against"
      expect(person_update.new_party_affiliation).to eq "republican_affiliation"
      expect(person_update.new_phone).to eq "123-456-7890"
      expect(person_update.new_preferred_contact_method).to eq "contact_by_phone"
      expect(person_update.new_previously_participated_in_caucus_or_primary).to eq false
    end
  end
end
