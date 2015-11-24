class AddLastVisitedByToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :last_visited_by_id, :integer

    Address.all.each do |address|
      visits = AddressUpdate.where(address: address).map(&:visit)
      if visits.length > 0
        latest_visit = visits.sort_by{ |visit| visit.updated_at }.last
        address.update(last_visited_by: latest_visit.user)
      end
    end
  end
end
