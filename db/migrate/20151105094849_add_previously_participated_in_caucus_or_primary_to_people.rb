class AddPreviouslyParticipatedInCaucusOrPrimaryToPeople < ActiveRecord::Migration
  def change
    add_column :people, :previously_participated_in_caucus_or_primary, :boolean, default: false
  end
end
