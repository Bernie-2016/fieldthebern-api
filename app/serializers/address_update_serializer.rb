class AddressUpdateSerializer < ActiveModel::Serializer
  attributes :id, :update_type

  belongs_to :address
  belongs_to :visit
end
