require "ground_game/parse_notification"

module GroundGame
  class ParseNotifier
    def self.ping_user(user: nil)
      Device.where(user: user).each do |device|
        ParseNotification.send_to_device(device_token: device.token, message: "Ping!")
      end
    end

    def self.ping_channel(channel: nil)
      ParseNotification.send_to_channel(channel: channel, message: "Ping!")
    end

    def self.friend_has_beaten_user(user: nil, friend: nil)
      message = "Your friend #{friend.first_name} has beaten you!"
      Device.where(user: user).each do |device|
        ParseNotification.send_to_device(device_token: device.token, message: message)
      end
    end

    # TODO: Define notification types we will use
  end
end
