class ChangeCanvasToCanvass < ActiveRecord::Migration
  def change
    rename_column :addresses, :best_canvas_response, :best_canvass_response
    rename_column :people, :canvas_response, :canvass_response
    rename_column :person_updates, :old_canvas_response, :old_canvass_response
    rename_column :person_updates, :new_canvas_response, :new_canvass_response
  end
end
