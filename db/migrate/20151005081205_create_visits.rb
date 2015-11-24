class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.float :total_points
      t.integer :duration_sec

      t.belongs_to :user, null: false
      t.belongs_to :address, null: false

      t.timestamps
    end
  end
end
