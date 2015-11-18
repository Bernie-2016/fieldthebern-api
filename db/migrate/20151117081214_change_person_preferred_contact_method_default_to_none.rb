class ChangePersonPreferredContactMethodDefaultToNone < ActiveRecord::Migration
  def change
    change_column :people, :preferred_contact_method, :string, default: nil
  end
end
