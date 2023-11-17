# frozen_string_literal: true

require "open3"
require "rack"
require "stringio"

RSpec.describe("when used as middleware") do
  let(:app) do
    opts = options
    Rack::Builder.new do
      use Rack::ECG, **opts
      run lambda { |env|
        if env["PATH_INFO"] == "/hello/world"
          [200, {}, ["Hello, World"]]
        else
          [404, {}, ["Goodbye, World"]]
        end
      }
    end
  end
  let(:options) do
    {} # empty default
  end

  context "main app" do
    it "responds OK for normal requests" do
      get "/hello/world"
      expect(last_response).to(be_ok)
    end

    it "doesn't include an X-Rack-ECG-Version custom header" do
      get "/hello/world"
      expect(last_response.headers["X-Rack-ECG-Version"]).to(be_nil)
    end
  end

  context "ecg app" do
    it "responds " do
      get "/_ecg"
      expect(last_response).to(be_ok)
    end

    it "includes an X-Rack-ECG-Version custom header" do
      get "/_ecg"
      expect(last_response.headers["X-Rack-ECG-Version"]).to(eq(Rack::ECG::VERSION))
    end

    context "when `at` config option is set" do
      let(:options) do
        { at: "/health_check" }
      end

      it "responds from that path" do
        get "/health_check"
        expect(last_response.headers["X-Rack-ECG-Version"]).to(eq(Rack::ECG::VERSION))
      end
    end

    context "when all checks pass" do
      it "has a success error code" do
        get "_ecg"
        expect(last_response.status).to(eq(200))
      end
    end

    context "when a checks errors" do
      let(:options) do
        { checks: [:error] }
      end
      it "has a failure error code" do
        get "_ecg"
        expect(last_response.status).to(eq(500))
      end

      context "with failure status option" do
        let(:options) do
          { checks: [:error], failure_status: 503 }
        end
        it "has a failure error code" do
          get "_ecg"
          expect(last_response.status).to(eq(503))
        end
      end
    end

    context "when hook config option is set" do
      let(:hook_proc) { instance_double(Proc) }
      let(:options) do
        { hook: hook_proc, checks: :error }
      end

      it "executes the hook proc with success status and check results as params" do
        expect(hook_proc).to(receive(:call)) do |success, check_results|
          expect(success).to(be_falsey)
          expect(check_results).to(have_key(:error))
        end
        get "_ecg"
        expect(last_response.status).to(eq(500))
      end
    end

    context "git revision" do
      let(:options) do
        { checks: [:git_revision] }
      end
      context "when available" do
        let(:sha) { "cafe1234" }
        it "is reported" do
          expect(Open3).to(receive(:popen3)
            .with("git rev-parse HEAD")
            .and_return([
              nil,                                                    # stdin
              StringIO.new(sha + "\n"),                               # stdout
              StringIO.new, # stderr
              double(value: double(Process::Status, success?: true)), # wait thread & process status
            ]))
          get "/_ecg"
          expect(json_body["git_revision"]["status"]).to(eq("ok"))
          expect(json_body["git_revision"]["value"]).to(eq(sha))
        end
      end

      context "when not available" do
        let(:error_message) { "git had a sad" }
        it "is reported" do
          expect(Open3).to(receive(:popen3)
            .with("git rev-parse HEAD")
            .and_return([
              nil, # stdin
              StringIO.new, # stdout
              StringIO.new(error_message + "\n"), # stderr
              double(value: double(Process::Status, success?: false)), # wait thread & process status
            ]))
          get "/_ecg"
          expect(json_body["git_revision"]["status"]).to(eq("error"))
          expect(json_body["git_revision"]["value"]).to(eq("git had a sad"))
        end
      end
    end

    context "migration version" do
      let(:options) do
        { checks: [:migration_version] }
      end
      let(:connection) { double("connection") }
      let(:version) { "123456" }

      context "when available" do
        it "is reported" do
          class ActiveRecord
            class Base
              class << self
                def connection
                end
              end
            end
          end
          expect(ActiveRecord::Base).to(receive(:connection).and_return(connection))
          expect(connection).to(receive(:select_value)
            .with("select max(version) from schema_migrations")
            .and_return(version))
          get "/_ecg"
          expect(json_body["migration_version"]["status"]).to(eq("ok"))
          expect(json_body["migration_version"]["value"]).to(eq(version))
        end
      end

      context "when not available" do
        it "is reported" do
          Object.send(:remove_const, :ActiveRecord) if defined?(ActiveRecord)
          get "/_ecg"
          expect(json_body["migration_version"]["status"]).to(eq("error"))
          expect(json_body["migration_version"]["value"]).to(eq("ActiveRecord not found"))
        end
      end
    end

    context "active_record" do
      let(:options) do
        { checks: [:active_record] }
      end
      context "when available" do
        let(:active) { true }
        let(:connection) { double("connection") }
        it "is reported" do
          class ActiveRecord
            class Base
              class << self
                def connection
                end
              end
            end
          end
          expect(ActiveRecord::Base).to(receive(:connection).and_return(connection))
          expect(connection).to(receive(:active?).and_return(active))
          get "/_ecg"
          expect(json_body["active_record"]["status"]).to(eq("ok"))
          expect(json_body["active_record"]["value"]).to(eq(active.to_s))
        end
      end

      context "when not available" do
        it "is reported" do
          Object.send(:remove_const, :ActiveRecord) if defined?(ActiveRecord)
          get "/_ecg"
          expect(json_body["active_record"]["status"]).to(eq("error"))
          expect(json_body["active_record"]["value"]).to(eq("ActiveRecord not found"))
        end
      end
    end

    context "redis" do
      let(:options) do
        { checks: [[:redis, { instance: instance }]] }
      end
      let(:instance) { instance_double("Redis", connected?: connected) }
      let(:connected) { true }

      before do
        # make sure Redis is defined
        class Redis
          def connected?
          end
        end unless defined?(Redis)
      end

      context "when available" do
        it "is reported" do
          expect(instance).to(receive(:connected?).and_return(connected))
          get "/_ecg"
          expect(json_body["redis"]["status"]).to(eq("ok"))
          expect(json_body["redis"]["value"]).to(eq(connected.to_s))
        end
      end

      context "the instance is not connected" do
        let(:connected) { false }

        it "is reported" do
          expect(instance).to(receive(:connected?).and_return(connected))
          get "/_ecg"
          expect(json_body["redis"]["status"]).to(eq("error"))
          expect(json_body["redis"]["value"]).to(eq(connected.to_s))
        end
      end

      context "without instance parameters" do
        let(:options) do
          { checks: [:redis] }
        end

        it "is reported" do
          get "/_ecg"
          expect(json_body["redis"]["status"]).to(eq("error"))
          expect(json_body["redis"]["value"]).to(eq("Redis instance parameters not found"))
        end
      end

      context "when not available" do
        it "is reported" do
          Object.send(:remove_const, :Redis) if defined?(Redis)
          get "/_ecg"
          expect(json_body["redis"]["status"]).to(eq("error"))
          expect(json_body["redis"]["value"]).to(eq("Redis not found"))
        end
      end
    end

    context "sequel" do
      let(:options) do
        { checks: [[:sequel, { name: "My Awesome DB", connection: "sqlite://" }]] }
      end
      let(:instance) { double("sequel_db") }

      context "when available" do
        it "is reported" do
          class Sequel
            class << self
              def connect(_)
              end
            end
          end
          expect(Sequel).to(receive(:connect).with("sqlite://").and_yield(instance))
          expect(instance).to(receive(:test_connection).and_return(true))
          get "/_ecg"
          expect(json_body["sequel_my_awesome_db"]["status"]).to(eq("ok"))
          expect(json_body["sequel_my_awesome_db"]["value"]).to(eq("true"))
        end
      end
    end

    context "static" do
      let(:options) do
        { checks: [[:static, static_options]] }
      end

      context "success is true" do
        let(:static_options) do
          { success: true, value: "ready" }
        end

        it "reports success" do
          get "/_ecg"
          expect(json_body["static"]["status"]).to(eq("ok"))
          expect(json_body["static"]["value"]).to(eq("ready"))
        end
      end

      context "success is false" do
        let(:static_options) do
          { success: false, value: "unhealthy" }
        end

        it "reports an error" do
          get "/_ecg"
          expect(json_body["static"]["status"]).to(eq("error"))
          expect(json_body["static"]["value"]).to(eq("unhealthy"))
        end
      end

      context "when a name is set" do
        let(:static_options) do
          { value: "this is the static value" }
        end

        it "reports under that name" do
          get "/_ecg"
          expect(json_body["static"]["value"]).to(eq("this is the static value"))
        end
      end

      context "when status is set" do
        let(:static_options) do
          { value: "no error", success: false, status: "ok" }
        end

        it "reports that status" do
          get "/_ecg"
          expect(json_body["static"]["status"]).to(eq("ok"))
        end
      end
    end
  end
end
