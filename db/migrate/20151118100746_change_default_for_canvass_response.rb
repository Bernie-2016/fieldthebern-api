class ChangeDefaultForCanvassResponse < ActiveRecord::Migration
  def change
    change_column :addresses, :best_canvass_response, :string, default: 'not_yet_visited'
    change_column :people, :canvass_response, :string, default: 'unknown'
  end
end
