class AddLastCanvassResponseTrackingToAddressUpdates < ActiveRecord::Migration
  def change
    add_column :address_updates, :old_last_canvass_response, :string
    add_column :address_updates, :new_last_canvass_response, :string
  end
end
