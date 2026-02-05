# frozen_string_literal: true

require "test_helper"

class TestShipyrdClient < Minitest::Test
  describe "#trigger" do
    after do
      Shipyrd::Client::ENV_VARS.each do |var|
        ENV.delete(var)
      end
    end

    describe "configuration" do
      it "when host isn't configured" do
        ENV["SHIPYRD_HOST"] = nil

        assert_equal Shipyrd::Client.new.host, "https://hooks.shipyrd.io"
      end

      it "host and api key can be passed in as arguments" do
        client = Shipyrd::Client.new(
          api_key: "secret",
          host: "localhost"
        )

        assert_equal "secret", client.api_key
        assert_equal "https://localhost", client.host
      end

      it "logger can be customized" do
        logger = Logger.new($stdout)

        client = Shipyrd::Client.new(
          logger: logger
        )

        assert_equal logger, client.logger
      end

      it "https protocol is automatically added to host" do
        ENV["SHIPYRD_HOST"] = "localhost"
        assert_equal "https://localhost", Shipyrd::Client.new.host
      end

      it "https protocol is not added to host if it's already there" do
        ENV["SHIPYRD_HOST"] = "https://localhost"
        assert_equal "https://localhost", Shipyrd::Client.new.host
      end

      it "when API key isn't configured" do
        ENV["SHIPYRD_API_KEY"] = nil
        ENV["SHIPYRD_HOST"] = "localhost"

        Shipyrd::Logger.any_instance.expects(:info).with("ENV['SHIPYRD_API_KEY'] is not configured, disabling")

        Shipyrd::Client.new
      end

      it "sets the performer" do
        ENV["KAMAL_PERFORMER"] = "n"

        client = Shipyrd::Client.new

        client.stubs(:`).with("gh config get -h github.com username").returns("")
        assert_equal ENV["KAMAL_PERFORMER"], client.performer

        client.stubs(:`).with("gh config get -h github.com username").returns("nickhammond")
        assert_equal "https://github.com/nickhammond", client.performer
      end

      it "sets the commit message to the first 50 characters from git logs" do
        client = Shipyrd::Client.new

        client.stubs(:`).with("git show -s --format=%s").returns("This is a commit message for some new fancy stuff that is longer than 90 characters and should get cut off")

        assert_equal "This is a commit message for some new fancy stuff that is longer than 90 characters and sho...", client.commit_message
      end
    end

    describe "triggering" do
      it "fails gracefully from failed network request" do
        ENV["SHIPYRD_HOST"] = "localhost"
        ENV["SHIPYRD_API_KEY"] = "secret"
        ENV["KAMAL_SERVICE_VERSION"] = "example@4152f8"

        client = Shipyrd::Client.new

        stub_request(
          :post,
          "#{client.host}/deploys.json"
        ).to_return(
          status: [500, "Application Error"]
        )

        Shipyrd::Logger.any_instance.expects(:info).with("deploy trigger failed with 500(Application Error)")

        client.trigger("deploy")
      end

      it "raises when destination is blocked" do
        ENV["SHIPYRD_HOST"] = "localhost"
        ENV["SHIPYRD_API_KEY"] = "secret"
        ENV["KAMAL_SERVICE_VERSION"] = "example@4152f8"

        client = Shipyrd::Client.new

        stub_request(
          :post,
          "#{client.host}/deploys.json"
        ).to_return(
          status: [422, "Unprocessable content"],
          body: {errors: {"lock": "Destination locked by user"}}.to_json
        )

        assert_raises(Shipyrd::Client::DestinationBlocked, "pre-deploy trigger failed with 'Destination locked by user'") do
          client.trigger("deploy")
        end
      end

      it "successfully records a deploy in shipyrd" do
        ENV["SHIPYRD_HOST"] = "localhost"
        ENV["SHIPYRD_API_KEY"] = "secret"
        ENV["KAMAL_RECORDED_AT"] = Time.now.to_s
        ENV["KAMAL_VERSION"] = "4152f876f56384f268fbdaa7a30dd2e5f5ee3894"
        ENV["KAMAL_SERVICE_VERSION"] = "example@4152f8"
        ENV["KAMAL_HOSTS"] = "867.530.9"
        ENV["KAMAL_COMMAND"] = "deploy"
        ENV["KAMAL_SUBCOMMAND"] = "thingz"
        ENV["KAMAL_ROLE"] = "web"
        ENV["KAMAL_DESTINATION"] = "production"
        ENV["KAMAL_RUNTIME"] = "125"

        client = Shipyrd::Client.new
        client.stubs(:performer).returns("nick")
        client.stubs(:commit_message).returns("This is a commit message")

        event = "deploy-event"
        env = client.env

        stub_request(
          :post,
          "#{client.host}/deploys.json"
        ).with(
          body: {
            deploy: {
              status: event,
              recorded_at: env["KAMAL_RECORDED_AT"],
              performer: client.performer,
              commit_message: client.commit_message,
              version: env["KAMAL_VERSION"],
              service_version: env["KAMAL_SERVICE_VERSION"],
              hosts: env["KAMAL_HOSTS"],
              command: env["KAMAL_COMMAND"],
              subcommand: env["KAMAL_SUBCOMMAND"],
              role: env["KAMAL_ROLE"],
              destination: env["KAMAL_DESTINATION"],
              runtime: env["KAMAL_RUNTIME"]
            }
          }.to_json,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer #{client.api_key}"
          }
        )

        Shipyrd::Logger.any_instance.expects(:info).with("deploy-event triggered successfully for example@4152f8")

        client.trigger(event)
      end
    end
  end
end
