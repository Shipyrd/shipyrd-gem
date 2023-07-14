# frozen_string_literal: true

require_relative "shipyrd/version"
require 'uri'
require 'net/http'
require 'json'

module Shipyrd
  class Error < StandardError; end

  def self.trigger(event)
    uri = URI("#{ENV['SHIPYRD_HOST']}/deploys.json")
    headers = {'Content-Type': 'application/json'}

    details = {
      deploy: {
        status: event,
        recorded_at: ENV['MRSK_RECORDED_AT'],
        performer: ENV['MRSK_PERFORMER'],
        version: ENV['MRSK_VERSION'],
        service_version: ENV['MRSK_SERVICE_VERSION'],
        hosts: ENV['MRSK_HOSTS'],
        command: ENV['MRSK_COMMAND'],
        subcommand: ENV['MRSK_SUBCOMMAND'],
        role: ENV['MRSK_ROLE'],
        destination: ENV['MRSK_DESTINATION'],
        runtime: ENV['MRSK_RUNTIME']
      }
    }

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.basic_auth '', ENV['SHIPYRD_API_KEY']
    request.body = details.to_json
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      puts "Shipyrd: triggered #{event} successfully"
    else
      puts "Shipyrd: failed to trigger #{event}"
    end
  end
end
