class CreateAddressUpdates < ActiveRecord::Migration
  def change
    create_table :address_updates do |t|
      t.belongs_to :address
      t.belongs_to :visit

      t.string :update_type, nullable: false, default: "created"
    end
  end
end
