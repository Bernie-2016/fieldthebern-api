class AddUspsVerifiedAddressFieldsToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :usps_verified_street_1, :string
    add_column :addresses, :usps_verified_street_2, :string
    add_column :addresses, :usps_verified_city, :string
    add_column :addresses, :usps_verified_state, :string
    add_column :addresses, :usps_verified_zip, :string
  end
end
