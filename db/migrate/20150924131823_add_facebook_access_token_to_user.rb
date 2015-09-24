class AddFacebookAccessTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :facebook_access_token, :text
  end
end
