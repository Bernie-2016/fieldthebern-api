class Visit < ActiveRecord::Base
  belongs_to :user
  belongs_to :address

  validates :user_id, presence: true
  validates :address_id, presence: true

  enum result: {
    not_visited: 'Not visited',
    not_home: 'Not home',
    not_interested: 'Not interested',
    interested: 'Interested',
    unsure: 'Not sure'
  }
end
