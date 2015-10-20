class PersonUpdate < ActiveRecord::Base
  belongs_to :person
  belongs_to :visit

  validates :person, presence: true
  validates :visit, presence: true
end
