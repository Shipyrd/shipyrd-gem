require "logger"

class Shipyrd::Logger < Logger
  def initialize
    super(
      $stdout,
      level: Logger::INFO,
      progname: "Shipyrd",
      formatter: proc do |severity, _datetime, progname, msg|
        "#{severity} -- #{progname}: #{msg}\n"
      end
    )
  end
end
