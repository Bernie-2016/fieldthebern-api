class AddNewAttributesToPersonUpdates < ActiveRecord::Migration
  def change
  	add_column :person_updates, :new_first_name, :string
  	add_column :person_updates, :old_first_name, :string
    add_column :person_updates, :old_last_name, :string
    add_column :person_updates, :new_last_name, :string
    add_column :person_updates, :old_address_id, :integer
    add_column :person_updates, :new_address_id, :integer
    add_column :person_updates, :old_email, :string
    add_column :person_updates, :new_email, :string
    add_column :person_updates, :old_phone, :string
    add_column :person_updates, :new_phone, :string
    add_column :person_updates, :old_preferred_contact_method, :string
    add_column :person_updates, :new_preferred_contact_method, :string
    add_column :person_updates, :old_previously_participated_in_caucus_or_primary, :boolean
    add_column :person_updates, :new_previously_participated_in_caucus_or_primary, :boolean
  end
end
