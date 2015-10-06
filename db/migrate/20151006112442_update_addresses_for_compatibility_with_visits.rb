class UpdateAddressesForCompatibilityWithVisits < ActiveRecord::Migration
  def up
    add_column :addresses, :latest_result, :string

    Address.all.each do |a|
      if a.result == 0
        a.update_attribute :latest_result, 'Not visited'
      elsif a.result == 1
        a.update_attribute :latest_result, 'Not home'
      elsif a.result == 2
        a.update_attribute :latest_result, 'Not interested'
      elsif a.result == 3
        a.update_attribute :latest_result, 'Interested'
      elsif a.result == 4
        a.update_attribute :latest_result, 'Unsure'
      end

      a.update_attribute :created_at, a.visited_at
      a.update_attribute :updated_at, a.visited_at
    end

    remove_column :addresses, :result
  end

  def down
    add_column :addresses, :result, :integer

    Address.all.each do |a|
      if a.latest_result == 'Not visited'
        a.update_attribute :result, 0
      elsif a.latest_result == 'Not home'
        a.update_attribute :result, 1
      elsif a.latest_result == 'Not interested'
        a.update_attribute :result, 2
      elsif a.latest_result == 'Interested'
        a.update_attribute :result, 3
      elsif a.latest_result == 'Unsure'
        a.update_attribute :result, 4
      end

      a.update_attribute :visited_at, a.updated_at
    end

    remove_column :addresses, :latest_result
  end
end
