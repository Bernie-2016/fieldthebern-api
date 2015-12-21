class MakeDeviceTokensNotNull < ActiveRecord::Migration
  def up
    Device.where(token: nil).destroy_all

    change_column_null :devices, :token, false
  end

  def down
    change_column_null :devices, :token, true
  end
end
