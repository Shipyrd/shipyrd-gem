# frozen_string_literal: true

ENV["CI"] = "true" # To silence stdout with minitest-silence

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "shipyrd"

require "minitest/autorun"
require "mocha/minitest"
require "minitest/reporters"
require "webmock/minitest"

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]
