module GroundGame
  class ParseNotification

    def initialize(username: nil, channel: nil, message: nil)
      @username = username
      @channel = channel
      @type = @username.present? ? 'individual' : 'channel'
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
        query.eq('username', @username.to_s)
        # setting deviceType in where clause
        query.eq('deviceType', 'android') if individual?
        query
      end
  end
end
