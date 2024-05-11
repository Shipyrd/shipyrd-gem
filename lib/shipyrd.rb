# frozen_string_literal: true

require_relative "shipyrd/version"
require "uri"
require "net/http"
require "json"

module Shipyrd
  class Error < StandardError; end

  class ConfigurationError < Error; end

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

  def self.trigger(event)
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
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = details.to_json

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      log "#{event} triggered successfully for #{details[:deploy][:service_version]}"
    else
      log "#{event} trigger failed with #{response.code}(#{response.message})"
    end
  rescue => e
    log "#{event} trigger failed with error => #{e}"
  end

  def self.env
    ENV.slice(*ENV_VARS)
  end

  def self.performer
    github_username = `gh config get -h github.com username`.chomp

    github_username.empty? ? ENV["KAMAL_PERFORMER"] : "https://github.com/#{github_username}"
  end

  def self.host
    raise ConfigurationError.new("ENV['SHIPYRD_HOST'] is not configured") unless env["SHIPYRD_HOST"]

    env["SHIPYRD_HOST"]
  end

  def self.api_key
    raise ConfigurationError.new("ENV['SHIPYRD_API_KEY'] is not configured") unless env["SHIPYRD_API_KEY"]

    env["SHIPYRD_API_KEY"]
  end

  def self.log(message)
    puts "Shipyrd: #{message}"
  end
end
