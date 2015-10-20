class Visit < ActiveRecord::Base
  belongs_to :user

  has_one :address_update
  has_one :address, through: :address_update
  has_many :person_updates
  has_many :people, through: :person_updates

  validates :user, presence: true
end
