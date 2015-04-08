RSpec.describe "when used as middleware" do
  let(:app) {
    opts = options
    Rack::Builder.new do
      use Rack::ECG, opts
      run -> (env) {
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

    context "when mounted_path is set" do
      let(:options) {
        {mounted_path: "/health_check"}
      }

      it "responds from that path" do
        get "/health_check"
        expect(last_response.header["X-Rack-ECG-Version"]).to eq(Rack::ECG::VERSION)
      end
    end

    context "git revision" do
      context "when available" do
        let(:sha) { "cafe1234" }
        it "is reported" do
          expect_any_instance_of(Rack::ECG).to receive(:`).with("git rev-parse HEAD").and_return(sha)
          expect($?).to receive(:success?).and_return(true)
          get "/_ecg"
          expect(last_response.body).to match(sha)
        end
      end

      context "when not available" do
        it "is reported" do
          expect_any_instance_of(Rack::ECG).to receive(:`).with("git rev-parse HEAD").and_return("")
          expect($?).to receive(:success?).and_return(false)
          get "/_ecg"
          expect(last_response.body).to match("unknown")
        end
      end
    end
  end
end
