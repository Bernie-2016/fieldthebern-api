class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :points_for_updates, default: 0
      t.integer :points_for_knock, default: 0

      t.belongs_to :visit
    end
  end
end
