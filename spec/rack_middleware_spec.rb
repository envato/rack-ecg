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
  end
end
