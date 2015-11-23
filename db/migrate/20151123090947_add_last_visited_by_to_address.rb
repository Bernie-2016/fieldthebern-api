class AddLastVisitedByToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :last_visited_by_id, :integer
  end
end
