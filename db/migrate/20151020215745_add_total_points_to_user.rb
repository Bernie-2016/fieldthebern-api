class AddTotalPointsToUser < ActiveRecord::Migration
  def change
    add_column :users, :total_points, :integer, default: 0
  end
end
