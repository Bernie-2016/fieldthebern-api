class Visit < ActiveRecord::Base
  belongs_to :user, counter_cache: true

  has_one :score

  has_one :address_update
  has_one :address, through: :address_update

  has_many :person_updates
  has_many :people, through: :person_updates

  validates :user, presence: true
  validates :address_update, presence: true

  scope :this_week, -> { where(created_at: Time.zone.now.all_week) }

  def number_of_updated_people
    person_updates.count
  end

end
