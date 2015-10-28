
class CustomLogger

  def self.error(message)
    puts red message
  end

  def self.debug(message)
  end

  def self.info(message)
  end

  private

    def self.colorize(color_code, message)
      "\e[#{color_code}m#{message}\e[0m"
    end

    def self.red(message)
      colorize(31, message)
    end

    def self.green(message)
      colorize(32, message)
    end
end

Parse.init application_id: ENV['PARSE_APPLICATION_ID'],
           api_key: ENV['PARSE_API_KEY'],
           quiet: false,
           logger: CustomLogger

