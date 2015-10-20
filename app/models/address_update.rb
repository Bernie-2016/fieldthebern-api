class AddressUpdate < ActiveRecord::Base
  belongs_to :address
  belongs_to :visit

  validates :address, presence: true
  validates :visit, presence: true

  def self.create_for_visit_and_address(visit, address)
    AddressUpdate.create(
      address: address,
      visit: visit,
      update_type: address.new_record? ? :created : :modified)
  end
end
