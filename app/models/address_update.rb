class AddressUpdate < ActiveRecord::Base
  belongs_to :address
  belongs_to :visit

  validates :address, presence: true
  validates :visit, presence: true
end
