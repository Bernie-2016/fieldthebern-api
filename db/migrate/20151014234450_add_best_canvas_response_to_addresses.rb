class AddBestCanvasResponseToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :best_canvas_response, :string, default: 'Not yet home'
  end
end
