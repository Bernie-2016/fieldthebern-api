class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.float :latitude
      t.float :longitude
      t.string :street_1
      t.string :street_2
      t.string :city
      t.string :state_code
      t.string :zip_code
      t.datetime :visited_at
      t.integer :result, default: 0
    end
  end
end
