class AddTimestampsToAddressUpdates < ActiveRecord::Migration
  def change
    add_column(:address_updates, :created_at, :datetime)
  end
end
