class User < ActiveRecord::Base
  ASSET_HOST_FOR_DEFAULT_PHOTO = 'http://www.example.com'

  include Clearance::User

  has_many :visits

  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  has_attached_file :photo, styles: { thumb: '150x150#', large: '500x500#'},
                    :default_url => ASSET_HOST_FOR_DEFAULT_PHOTO + '/default_:style.png  '

  validates_attachment_content_type :photo,
                                    content_type: %r{^image\/(png|gif|jpeg)}

  def self.friendly_token
    # Borrowed from Devise.friendly_token
    SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz').first(12)
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  def total_points_this_week
    return visits.this_week.sum(:total_points)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def ranking_name
    if !full_name.strip.empty?
      full_name
    else
      email[/[^@]+/]
    end
  end

  def ranking_data_json
    return {
      name: ranking_name,
      photo_thumb_url: photo.url(:thumb)
    }.to_json
  end
  
  def decode_image_data
    return unless base_64_photo_data.present?
    data = StringIO.new(Base64.decode64(base_64_photo_data))
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = SecureRandom.hex + '.png'
    data.content_type = 'image/png'
    self.photo = data
  end
end
