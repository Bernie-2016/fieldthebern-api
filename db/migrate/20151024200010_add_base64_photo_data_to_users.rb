class AddBase64PhotoDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :base_64_photo_data, :string
  end
end
