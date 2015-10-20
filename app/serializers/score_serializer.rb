class ScoreSerializer < ActiveModel::Serializer
  attributes :id, :points_for_updates, :points_for_knock

  belongs_to :visit
end
