module GroundGame
  class AddressUnmatched < StandardError
    def initialize
      super "The requested address does not exist in the database."
    end
  end
end
