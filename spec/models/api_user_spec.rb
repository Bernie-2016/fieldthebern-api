require 'rails_helper'

RSpec.describe ApiUser, type: :model do
  context 'schema' do
    it { should have_db_column(:api_access_token).of_type(:string) }
    it { should have_db_column(:api_user_id).of_type(:integer) }
    it { should have_db_column(:user_id).of_type(:integer) }
  end

  context 'associations' do
    it { should belong_to(:user) }
  end
end
