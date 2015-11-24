class UpdateVisitsRemoveAddressReference < ActiveRecord::Migration
  def change
    remove_reference :visits, :address, index: true
  end
end
