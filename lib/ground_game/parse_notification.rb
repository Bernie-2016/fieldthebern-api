module GroundGame
  class ParseNotification

    def self.send_to_device(device_token: nil, message: nil)
      new(device_token: device_token, message: message).send
    end

    def self.send_to_channel(channel: nil, message: nil)
      new(channel: channel, message: message).send
    end

    def initialize(device_token: nil, channel: nil, message: nil, device_type: "ios")
      @device_token = device_token
      @type = @device_token.present? ? 'individual' : 'channel'
      @device_type =  device_type
      @channel = channel
      @message = message
    end

    def send
      if individual?
        push = Parse::Push.new(data) if individual?
        push.where = query.where if individual?
      end

      push = Parse::Push.new(data, @channel) if channel?

      push.type = "ios" if channel?

      push.save
    end

    private

      def individual?
        @type == 'individual'
      end

      def channel?
        @type == 'channel'
      end

      def data
        { alert: @message }
      end

      def query
        # initialize query object
        query = Parse::Query.new(Parse::Protocol::CLASS_INSTALLATION)
        # set query where clause by some attribute
        query.eq('username', @device_token.to_s)
        # setting deviceType in where clause
        query.eq('deviceType', @device_type) if individual?
        query
      end
  end
end
