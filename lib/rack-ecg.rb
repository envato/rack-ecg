require "rack-ecg/version"

module Rack
  class ECG
    def initialize(app, options={})
      @app = app
      @options = options
    end

    def call(env)
      request = Rack::Request.new(env)
      if request.path_info == mounted_path
        [200, {"X-Rack-ECG-Version" => Rack::ECG::VERSION}, ["Rack::ECG"]]
      else
        @app.call(env)
      end
    end

    private
    def mounted_path
      "/_ecg"
    end
  end
end
