class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.references :user, index: true, foreign_key: true
      t.string :token
      t.boolean :enabled
      t.string :platform

      t.timestamps null: false
    end

    add_index :devices, :token, unique: true
  end
end
