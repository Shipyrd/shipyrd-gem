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
    SHIPYRD_HOST
  ]

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
        recorded_at: ENV["KAMAL_RECORDED_AT"],
        performer: performer,
        commit_message: commit_message,
        version: ENV["KAMAL_VERSION"],
        service_version: ENV["KAMAL_SERVICE_VERSION"],
        hosts: ENV["KAMAL_HOSTS"],
        command: ENV["KAMAL_COMMAND"],
        subcommand: ENV["KAMAL_SUBCOMMAND"],
        role: ENV["KAMAL_ROLE"],
        destination: ENV["KAMAL_DESTINATION"],
        runtime: ENV["KAMAL_RUNTIME"]
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
    else
      logger.info "#{event} trigger failed with #{response.code}(#{response.message})"
    end
  rescue => e
    logger.info "#{event} trigger failed with error => #{e}"
  end

  def env
    ENV.slice(*ENV_VARS)
  end

  def performer
    github_username.empty? ? ENV["KAMAL_PERFORMER"] : "https://github.com/#{github_username}"
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
    valid_host? && valid_api_key?

    true
  rescue ArgumentError => e
    logger.info(e.to_s)

    false
  end

  def valid_host?
    raise ArgumentError, "ENV['SHIPYRD_HOST'] is not configured, disabling" unless host

    true
  end

  def valid_api_key?
    raise ArgumentError, "ENV['SHIPYRD_API_KEY'] is not configured, disabling" unless api_key

    true
  end

  def parse_host(host)
    return nil unless host
    return host if host.start_with?("https")

    "https://#{host}"
  end
end
