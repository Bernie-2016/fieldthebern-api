require 'rails_helper'

describe Visit do
  it "has a valid factory" do
    expect(build(:visit)).to be_valid
  end

  context 'schema' do
    it {should have_db_column(:total_points).of_type(:float) }
    it {should have_db_column(:duration_sec).of_type(:integer) }
    it {should have_db_column(:user_id).of_type(:integer) }
    it {should have_db_column(:created_at).of_type(:datetime) }
    it {should have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'associations' do
    it { should have_one(:score) }
    it { should have_one(:address_update) }
    it { should have_many(:person_updates) }
    it { should have_one(:address) }
    it { should have_many(:people) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:address_update) }
  end

  context 'scopes' do
    it "has a working 'this_week' scope" do
      user = create(:user)
      create_list(:visit, 7, user: user, total_points: 10, created_at: Time.now)
      create_list(:visit, 5, user: user, total_points: 1, created_at: Time.now - 8.days)
      expect(Visit.this_week.count).to eq 7
    end
  end

  context 'instance methods' do
    it 'should count the number of people updated with #number_of_updated_people' do
      visit = build(:visit)
      expect(visit.number_of_updated_people).to eq 0
      visit_with_people = build(:visit, :with_people, people_count: 2)
      expect(visit_with_people.number_of_updated_people).to eq 2
    end
  end
end
