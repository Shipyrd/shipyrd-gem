# frozen_string_literal: true

require "test_helper"

class TestShipyrd < Minitest::Test
  describe "#trigger" do
    before do
      # shipyrd config
      ENV["SHIPYRD_HOST"] = "http://localhost"
      ENV["SHIPYRD_API_KEY"] = "secret"

      # mrsk env
      ENV["MRSK_RECORDED_AT"] = Time.now.to_s
      ENV["MRSK_PERFORMER"] = "n"
      ENV["MRSK_VERSION"] = "4152f876f56384f268fbdaa7a30dd2e5f5ee3894"
      ENV["MRSK_SERVICE_VERSION"] = "example@#{ENV["MRSK_VERSION"][0..6]}"
      ENV["MRSK_HOSTS"] = "867.530.9"
      ENV["MRSK_COMMAND"] = "deploy"
      ENV["MRSK_SUBCOMMAND"] = "thingz"
      ENV["MRSK_ROLE"] = "web"
      ENV["MRSK_DESTINATION"] = "production"
      ENV["MRSK_RUNTIME"] = "125"
    end

    describe "failing from configuration" do
      it "when host isn't configured" do
        ENV["SHIPYRD_HOST"] = nil
        Shipyrd.trigger("deploy")
      end

      it "when api key isn't configured" do
        ENV["SHIPYRD_API_KEY"] = nil
        assert_not_requested(:post, ENV["SHIPYRD_HOST"])
        Shipyrd.trigger("deploy")
      end
    end

    it "successfully records a deploy in shipyrd" do
      event_name = "deploy-event"

      stub_request(
        :post,
        "#{ENV["SHIPYRD_HOST"]}/deploys.json"
      ).with(
        body: {
          deploy: {
            status: event_name,
            recorded_at: ENV["MRSK_RECORDED_AT"],
            performer: ENV["MRSK_PERFORMER"],
            version: ENV["MRSK_VERSION"],
            service_version: ENV["MRSK_SERVICE_VERSION"],
            hosts: ENV["MRSK_HOSTS"],
            command: ENV["MRSK_COMMAND"],
            subcommand: ENV["MRSK_SUBCOMMAND"],
            role: ENV["MRSK_ROLE"],
            destination: ENV["MRSK_DESTINATION"],
            runtime: ENV["MRSK_RUNTIME"]
          }
        },
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer #{ENV["SHIPYRD_API_KEY"]}"
        }
      )

      Shipyrd.trigger(event_name)
    end
  end
end
