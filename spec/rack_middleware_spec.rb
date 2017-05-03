require "open3"
require "stringio"

RSpec.describe "when used as middleware" do
  let(:app) {
    opts = options
    Rack::Builder.new do
      use Rack::ECG, opts
      run lambda {|env|
        if env["PATH_INFO"] == "/hello/world"
          [200, {}, ["Hello, World"]]
        else
          [404, {}, ["Goodbye, World"]]
        end
      }
    end
  }
  let(:options) {
    {} # empty default
  }

  context "main app" do
    it "responds OK for normal requests" do
      get "/hello/world"
      expect(last_response).to be_ok
    end

    it "doesn't include an X-Rack-ECG-Version custom header" do
      get "/hello/world"
      expect(last_response.header["X-Rack-ECG-Version"]).to be_nil
    end
  end

  context "ecg app" do
    it "responds " do
      get "/_ecg"
      expect(last_response).to be_ok
    end

    it "includes an X-Rack-ECG-Version custom header" do
      get "/_ecg"
      expect(last_response.header["X-Rack-ECG-Version"]).to eq(Rack::ECG::VERSION)
    end

    context "when `at` config option is set" do
      let(:options) {
        {at: "/health_check"}
      }

      it "responds from that path" do
        get "/health_check"
        expect(last_response.header["X-Rack-ECG-Version"]).to eq(Rack::ECG::VERSION)
      end
    end

    context "when all checks pass" do
      it "has a success error code" do
        get "_ecg"
        expect(last_response.status).to eq(200)
      end
    end

    context "when a checks errors" do
      let(:options) {
        { checks: [:error] }
      }
      it "has a success error code" do
        get "_ecg"
        expect(last_response.status).to eq(500)
      end
    end

    context "when hook config option is set" do
      let(:hook_proc) { instance_double(Proc) }
      let(:options) {
        { hook: hook_proc, checks: :error }
      }

      it "executes the hook proc with success status and check results as params" do
        expect(hook_proc).to receive(:call) do |success, check_results|
          expect(success).to be_falsey
          expect(check_results).to have_key(:error)
        end
        get "_ecg"
        expect(last_response.status).to eq(500)
      end
    end

    context "git revision" do
      let(:options) {
        { checks: [:git_revision] }
      }
      context "when available" do
        let(:sha) { "cafe1234" }
        it "is reported" do
          expect(Open3).to receive(:popen3).
            with("git rev-parse HEAD").
            and_return([
              nil,                                                    # stdin
              StringIO.new(sha + "\n"),                               # stdout
              StringIO.new(),                                         # stderr
              double(value: double(Process::Status, success?: true))  # wait thread & process status
            ])
          get "/_ecg"
          expect(json_body["git_revision"]["status"]).to eq("ok")
          expect(json_body["git_revision"]["value"]).to eq(sha)
        end
      end

      context "when not available" do
        let(:error_message) { "git had a sad" }
        it "is reported" do
          expect(Open3).to receive(:popen3).
            with("git rev-parse HEAD").
            and_return([
              nil,                                                    # stdin
              StringIO.new(),                                         # stdout
              StringIO.new(error_message + "\n"),                     # stderr
              double(value: double(Process::Status, success?: false)) # wait thread & process status
            ])
          get "/_ecg"
          expect(json_body["git_revision"]["status"]).to eq("error")
          expect(json_body["git_revision"]["value"]).to eq("git had a sad")
        end
      end
    end

    context "migration version" do
      let(:options) {
        { checks: [:migration_version] }
      }
      context "when available" do
        it "is reported" do
          class ActiveRecord
            class Base
              def self.connection
              end
            end
          end
          version = "123456"
          connection = double("connection")
          expect(ActiveRecord::Base).to receive(:connection).and_return(connection)
          expect(connection).to receive(:select_value).
            with("select max(version) from schema_migrations").
            and_return(version)
          get "/_ecg"
          expect(json_body["migration_version"]["status"]).to eq("ok")
          expect(json_body["migration_version"]["value"]).to eq(version)
        end
      end

      context "when not available" do
        it "is reported" do
          Object.send(:remove_const, :ActiveRecord) if defined?(ActiveRecord)
          get "/_ecg"
          expect(json_body["migration_version"]["status"]).to eq("error")
          expect(json_body["migration_version"]["value"]).to eq("ActiveRecord not found")
        end
      end
    end

    context "active_record" do
      let(:options) {
        { checks: [:active_record] }
      }
      context "when available" do
        it "is reported" do
          class ActiveRecord
            class Base
              def self.connection
              end
            end
          end
          active = true
          connection = double("connection")
          expect(ActiveRecord::Base).to receive(:connection).and_return(connection)
          expect(connection).to receive(:active?).and_return(active)
          get "/_ecg"
          expect(json_body["active_record"]["status"]).to eq("ok")
          expect(json_body["active_record"]["value"]).to eq(active.to_s)
        end
      end

      context "when not available" do
        it "is reported" do
          Object.send(:remove_const, :ActiveRecord) if defined?(ActiveRecord)
          get "/_ecg"
          expect(json_body["active_record"]["status"]).to eq("error")
          expect(json_body["active_record"]["value"]).to eq("ActiveRecord not found")
        end
      end
    end

    context "redis" do
      let(:options) {
        { checks: [:redis] }
      }
      context "when available" do
        it "is reported" do
          class Redis
            def self.current
            end
          end
          connected = true
          instance = double("current")
          expect(Redis).to receive(:current).and_return(instance)
          expect(instance).to receive(:connected?).and_return(connected)
          get "/_ecg"
          expect(json_body["redis"]["status"]).to eq("ok")
          expect(json_body["redis"]["value"]).to eq(connected.to_s)
        end
      end

      context "when not available" do
        it "is reported" do
          Object.send(:remove_const, :Redis) if defined?(Redis)
          get "/_ecg"
          expect(json_body["redis"]["status"]).to eq("error")
          expect(json_body["redis"]["value"]).to eq("Redis not found")
        end
      end
    end
  end
end
