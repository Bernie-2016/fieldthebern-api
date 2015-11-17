class AddNewTrackingAttributesToAddressUpdates < ActiveRecord::Migration
  def change
      add_column :address_updates, :old_latitude, :float
      add_column :address_updates, :old_longitude, :float
      add_column :address_updates, :old_street_1, :string
      add_column :address_updates, :old_street_2, :string
      add_column :address_updates, :old_city, :string
      add_column :address_updates, :old_state_code, :string
      add_column :address_updates, :old_zip_code, :string
      add_column :address_updates, :old_visited_at, :datetime
      add_column :address_updates, :old_most_supportive_resident_id, :integer
      add_column :address_updates, :old_best_canvass_response, :string

      add_column :address_updates, :new_latitude, :float
      add_column :address_updates, :new_longitude, :float
      add_column :address_updates, :new_street_1, :string
      add_column :address_updates, :new_street_2, :string
      add_column :address_updates, :new_city, :string
      add_column :address_updates, :new_state_code, :string
      add_column :address_updates, :new_zip_code, :string
      add_column :address_updates, :new_visited_at, :datetime
      add_column :address_updates, :new_most_supportive_resident_id, :integer
      add_column :address_updates, :new_best_canvass_response, :string
  end
end
