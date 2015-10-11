class Visit < ActiveRecord::Base
  belongs_to :user
  belongs_to :address
  has_many :people, through: :address

  validates :user_id, presence: true
  validates :address_id, presence: true
end
