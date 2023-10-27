# frozen_string_literal: true

require "test_helper"

class TestShipyrd < Minitest::Test
  describe "#trigger" do
    before do
      # shipyrd config
      ENV["SHIPYRD_HOST"] = "http://localhost"
      ENV["SHIPYRD_API_KEY"] = "secret"

      # Kamal env
      ENV["KAMAL_RECORDED_AT"] = Time.now.to_s
      ENV["KAMAL_PERFORMER"] = "n"
      ENV["KAMAL_VERSION"] = "4152f876f56384f268fbdaa7a30dd2e5f5ee3894"
      ENV["KAMAL_SERVICE_VERSION"] = "example@#{ENV["KAMAL_VERSION"][0..6]}"
      ENV["KAMAL_HOSTS"] = "867.530.9"
      ENV["KAMAL_COMMAND"] = "deploy"
      ENV["KAMAL_SUBCOMMAND"] = "thingz"
      ENV["KAMAL_ROLE"] = "web"
      ENV["KAMAL_DESTINATION"] = "production"
      ENV["KAMAL_RUNTIME"] = "125"
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
