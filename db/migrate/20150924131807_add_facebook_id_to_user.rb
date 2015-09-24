class AddFacebookIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :facebook_id, :string
  end
end
