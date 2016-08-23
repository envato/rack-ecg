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

    context "constant" do
      let(:options) do
        {
          checks: [:constant],
          check_options: { constant: { name: constant_name } }
        }
      end

      context "when availabile" do
        let(:constant_name) { "RUBY_VERSION" }

        it "is reported" do
          get "/_ecg"
          expect(json_body["constant"]["status"]).to eq("ok")
          expect(json_body["constant"]["value"]).to eq(RUBY_VERSION)
        end
      end

      context "When constant is missing" do
        let(:constant_name) { "UNDEFINED_CONSTANT" }
        it "is reported" do
          get "/_ecg"
          expect(json_body["constant"]["status"]).to eq("error")
          expect(json_body["constant"]["value"]).to eq("Constant ( UNDEFINED_CONSTANT ) missing")
        end
      end
    end

    context "migration version" do
      let(:options) {
        { checks: [:migration_version] }
      }
      context "when availabile" do
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
          expect(connection).to receive(:execute).
            with("select max(version) as version from schema_migrations").
            and_return([{"version" => version}])
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
  end
end
