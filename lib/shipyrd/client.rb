class Shipyrd::Client
  attr_reader :host, :api_key, :logger, :valid_configuration

  ENV_VARS = %w[
    KAMAL_COMMAND
    KAMAL_DESTINATION
    KAMAL_HOSTS
    KAMAL_PERFORMER
    KAMAL_RECORDED_AT
    KAMAL_ROLE
    KAMAL_RUNTIME
    KAMAL_SERVICE_VERSION
    KAMAL_SUBCOMMAND
    KAMAL_VERSION
    SHIPYRD_API_KEY
    SHIPYRD_COMMAND
    SHIPYRD_COMMIT_MESSAGE
    SHIPYRD_DESTINATION
    SHIPYRD_HOST
    SHIPYRD_HOSTS
    SHIPYRD_PERFORMER
    SHIPYRD_RECORDED_AT
    SHIPYRD_ROLE
    SHIPYRD_RUNTIME
    SHIPYRD_SERVICE_VERSION
    SHIPYRD_SUBCOMMAND
    SHIPYRD_VERSION
  ]

  class DestinationBlocked < StandardError; end

  def initialize(host: ENV["SHIPYRD_HOST"], api_key: ENV["SHIPYRD_API_KEY"], **options)
    @host = parse_host(host)
    @api_key = api_key
    @logger = options[:logger] || Shipyrd::Logger.new
    @valid_configuration = validate_configuration
  end

  def trigger(event)
    return false unless valid_configuration

    uri = URI("#{host}/deploys.json")
    headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer #{api_key}"
    }

    details = {
      deploy: {
        status: event,
        recorded_at: env_var("RECORDED_AT"),
        performer: performer,
        commit_message: ENV["SHIPYRD_COMMIT_MESSAGE"] || commit_message,
        version: env_var("VERSION"),
        service_version: env_var("SERVICE_VERSION"),
        hosts: env_var("HOSTS"),
        command: env_var("COMMAND"),
        subcommand: env_var("SUBCOMMAND"),
        role: env_var("ROLE"),
        destination: env_var("DESTINATION"),
        runtime: env_var("RUNTIME")
      }
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 5
    http.write_timeout = 5
    http.open_timeout = 5
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = details.to_json

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      logger.info "#{event} triggered successfully for #{details[:deploy][:service_version]}"
    elsif response.is_a?(Net::HTTPUnprocessableEntity)
      json_response = JSON.parse(response.body)

      if (lock = json_response.dig("errors", "lock"))
        raise DestinationBlocked, lock
      else
        logger.info "#{event} trigger failed with errors => #{json_response["errors"]}"
      end
    else
      logger.info "#{event} trigger failed with #{response.code}(#{response.message})"
    end
  rescue DestinationBlocked
    raise
  rescue => e
    logger.info "#{event} trigger failed with error => #{e}"
  end

  def env
    ENV.slice(*ENV_VARS)
  end

  def performer
    github_username.empty? ? env_var("PERFORMER") : "https://github.com/#{github_username}"
  end

  def github_username
    `gh config get -h github.com username`.chomp
  rescue
    "" # gh config get returns an empty string when not set
  end

  def commit_message
    message = `git show -s --format=%s`.chomp

    if message.length >= 90
      "#{message[0..90]}..."
    else
      message
    end
  end

  def validate_configuration
    valid_api_key?

    true
  rescue ArgumentError => e
    logger.info(e.to_s)

    false
  end

  def valid_api_key?
    raise ArgumentError, "ENV['SHIPYRD_API_KEY'] is not configured, disabling" unless api_key

    true
  end

  def parse_host(host)
    return "https://hooks.shipyrd.io" if host.nil?
    return host if host.start_with?("https")

    "https://#{host}"
  end

  private

  def env_var(name)
    ENV["SHIPYRD_#{name}"] || ENV["KAMAL_#{name}"]
  end
end
