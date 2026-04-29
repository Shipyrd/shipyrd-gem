# frozen_string_literal: true

class Shipyrd::Configuration
  attr_writer :host, :api_key, :commit_message,
    :recorded_at, :performer, :version, :service_version,
    :hosts, :command, :subcommand, :role, :destination, :runtime

  def host
    @host || ENV["SHIPYRD_HOST"]
  end

  def api_key
    @api_key || ENV["SHIPYRD_API_KEY"]
  end

  def commit_message
    @commit_message || ENV["SHIPYRD_COMMIT_MESSAGE"]
  end

  def recorded_at
    @recorded_at || ENV["SHIPYRD_RECORDED_AT"] || ENV["KAMAL_RECORDED_AT"]
  end

  def performer
    @performer || ENV["SHIPYRD_PERFORMER"] || ENV["KAMAL_PERFORMER"]
  end

  def version
    @version || ENV["SHIPYRD_VERSION"] || ENV["KAMAL_VERSION"]
  end

  def service_version
    @service_version || ENV["SHIPYRD_SERVICE_VERSION"] || ENV["KAMAL_SERVICE_VERSION"]
  end

  def hosts
    @hosts || ENV["SHIPYRD_HOSTS"] || ENV["KAMAL_HOSTS"]
  end

  def command
    @command || ENV["SHIPYRD_COMMAND"] || ENV["KAMAL_COMMAND"]
  end

  def subcommand
    @subcommand || ENV["SHIPYRD_SUBCOMMAND"] || ENV["KAMAL_SUBCOMMAND"]
  end

  def role
    @role || ENV["SHIPYRD_ROLE"] || ENV["KAMAL_ROLE"]
  end

  def destination
    @destination || ENV["SHIPYRD_DESTINATION"] || ENV["KAMAL_DESTINATION"]
  end

  def runtime
    @runtime || ENV["SHIPYRD_RUNTIME"] || ENV["KAMAL_RUNTIME"]
  end
end
