class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.string :canvas_response
      t.string :party_affiliation

      t.belongs_to :address

      t.timestamps
    end
  end
end
