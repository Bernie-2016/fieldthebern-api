class CreatePersonUpdates < ActiveRecord::Migration
  def change
    create_table :person_updates do |t|
      t.belongs_to :person
      t.belongs_to :visit

      t.string :update_type, default: "modify"

      t.string :old_canvas_response, nullable: true
      t.string :new_canvas_response, nullable: false
      t.string :old_party_affiliation, nullable: true
      t.string :new_party_affiliation, nullable: false
    end
  end
end
