class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.string :canvas_response, default: 'Unknown'
      t.string :party_affiliation, default: 'Unknown'

      t.belongs_to :address

      t.timestamps
    end
  end
end
