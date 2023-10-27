# frozen_string_literal: true

require_relative "shipyrd/version"
require "uri"
require "net/http"
require "json"

module Shipyrd
  class Error < StandardError; end

  def self.trigger(event)
    raise "ENV['SHIPYRD_HOST'] is not configured, skipping trigger" unless ENV["SHIPYRD_HOST"]
    raise "ENV['SHIPYRD_API_KEY'] is not configured, skipping trigger" unless ENV["SHIPYRD_API_KEY"]

    log "Triggering #{event} to #{ENV["SHIPYRD_HOST"]}"

    uri = URI("#{ENV["SHIPYRD_HOST"]}/deploys.json")
    headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer #{ENV["SHIPYRD_API_KEY"]}"
    }

    details = {
      deploy: {
        status: event,
        recorded_at: ENV["KAMAL_RECORDED_AT"],
        performer: ENV["KAMAL_PERFORMER"],
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
      log "#{event} trigger failed for #{details[:deploy][:service_version]} with #{response.code} #{response.message}"
    end
  rescue => e
    log "#{event} trigger failed with error => #{e}"
  end

  def self.log(message)
    puts "Shipyrd: #{message}"
  end
end
