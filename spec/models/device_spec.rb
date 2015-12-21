require 'rails_helper'

describe Device, type: :model do
  context 'schema' do
    it { should have_db_column(:platform).of_type(:string) }
    it { should have_db_column(:enabled).of_type(:boolean) }
    it { should have_db_column(:token).of_type(:string) }
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
    it { should have_db_index(:token) }
  end

  context 'associations' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:platform) }
    it { should validate_presence_of(:token) }
    it { should validate_presence_of(:user) }
  end
end
