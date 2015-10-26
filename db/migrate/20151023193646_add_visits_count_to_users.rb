class AddVisitsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :visits_count, :integer, default: 0
  end
end
