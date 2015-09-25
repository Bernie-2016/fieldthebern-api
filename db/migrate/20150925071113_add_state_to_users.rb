class AddStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :federal_state, :string
  end
end
