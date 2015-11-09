class AddEmailPhonePreferredContactMethodToPeople < ActiveRecord::Migration
  def change
    add_column :people, :email, :string
    add_column :people, :phone, :string
    add_column :people, :preferred_contact_method, :string, default: "email"
  end
end
