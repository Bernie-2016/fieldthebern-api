class AddLastCanvasResponseToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :last_canvass_response, :string, default: 'Unknown'
  end
end
