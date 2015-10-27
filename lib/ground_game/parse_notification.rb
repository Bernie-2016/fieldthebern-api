module GroundGame
  class ParseNotification

    attr_accessor :username, :channel, :type, :data, :message, :push

    def initialize(username: nil, channel: nil, message: nil)
      @username = username
      @channel = channel
      @type = @username.present? ? 'individual' : 'channel'
      @message = message
    end

    def send
      # initialize push object
      @push = if individual?
                Parse::Push.new(data)
              else
                Parse::Push.new(data, channel)
              end

      @push.type = "ios" if channel?
      @push.where = query.where if individual?

      @push.save
    end

    private

      def individual?
        type == 'individual'
      end

      def channel?
        type == 'channel'
      end

      def data
        { alert: @message }
      end

      def query
        # initialize query object
        @query = Parse::Query.new(Parse::Protocol::CLASS_INSTALLATION)
        # set query where clause by some attribute
        @query.eq('username', @username.to_s)
        # setting deviceType in where clause
        @query.eq('deviceType', 'android') if individual?
        @query
      end
  end
end
