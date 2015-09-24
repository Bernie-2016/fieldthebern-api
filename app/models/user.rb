class User < ActiveRecord::Base
  include Clearance::User

  def self.friendly_token
    # Borrowed from Devise.friendly_token
    SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz').first(12)
  end
end
