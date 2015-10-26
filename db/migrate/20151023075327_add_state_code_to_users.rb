class AddStateCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :state_code, :string
  end
end
