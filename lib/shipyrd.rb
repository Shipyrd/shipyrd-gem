# frozen_string_literal: true

require_relative "shipyrd/version"
require_relative "shipyrd/configuration"
require "uri"
require "net/http"
require "json"
require "logger"
require "shipyrd/client"
require "shipyrd/logger"

module Shipyrd
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Shipyrd::Configuration.new
    end

    def reset_configuration!
      @configuration = nil
    end
  end
end
