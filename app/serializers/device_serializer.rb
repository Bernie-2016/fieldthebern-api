class DeviceSerializer < ActiveModel::Serializer
  attributes :id, :token, :platform, :enabled

  belongs_to :user
end
