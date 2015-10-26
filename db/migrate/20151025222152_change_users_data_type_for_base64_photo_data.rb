class ChangeUsersDataTypeForBase64PhotoData < ActiveRecord::Migration
  def change
    change_column :users, :base_64_photo_data,  :text
  end
end
