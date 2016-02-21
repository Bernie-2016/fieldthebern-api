class CreateApiUsers < ActiveRecord::Migration
  def change
    create_table :api_users do |t|
      t.string  :api_access_token
      t.integer :api_user_id
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
