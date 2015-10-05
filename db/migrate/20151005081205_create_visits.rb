class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.float :submitted_latitude
      t.float :submitted_longitude
      t.float :corrected_latitude
      t.float :corrected_longitude

      t.string :submitted_street_1
      t.string :submitted_street_2
      t.string :submitted_city
      t.string :submitted_state_code
      t.string :submitted_zip_code

      t.float :total_points

      t.integer :duration_sec

      t.string :result, null: false

      t.integer :user_id, null: false
      t.integer :address_id, null: false

      t.timestamps
    end

    add_index :visits, :user_id
    add_index :visits, :address_id
  end
end
