class UpdateAddressForCompatibilityWithVisits < ActiveRecord::Migration
  def change
    add_column :addresses, :most_supportive_resident_id, :integer
    remove_column :addresses, :result, :integer
  end
end
