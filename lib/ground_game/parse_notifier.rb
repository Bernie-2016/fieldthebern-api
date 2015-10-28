module GroundGame
  class ParseNotifier
    def self.ping(username: nil, channel: nil)
      ParseNotification.send(username: username, channel: channel, message: "Ping!")
    end

    # TODO: Define notification types we will use
  end
end
