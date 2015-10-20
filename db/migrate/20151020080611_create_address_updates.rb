class CreateAddressUpdates < ActiveRecord::Migration
  def change
    create_table :address_updates do |t|
      t.belongs_to :address
      t.belongs_to :visit

      t.string :update_type, default: "modify"
    end
  end
end
