class RankingSerializer < ActiveModel::Serializer
  attributes :id, :score, :rank

  belongs_to :user
end