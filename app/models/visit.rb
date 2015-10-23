class Visit < ActiveRecord::Base
  belongs_to :user

  has_one :score

  has_one :address_update
  has_one :address, through: :address_update

  has_many :person_updates
  has_many :people, through: :person_updates

  validates :user, presence: true

  scope :this_week, -> { where(created_at: Date.today.at_beginning_of_week..Date.today.at_end_of_week) }

  def number_of_updated_people
    person_updates.count
  end

end
