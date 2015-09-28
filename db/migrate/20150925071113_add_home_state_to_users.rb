class AddHomeStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :home_state, :string
  end
end
