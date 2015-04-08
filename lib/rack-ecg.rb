require "rack-ecg/version"

module Rack
  class ECG
    DEFAULT_MOUNTED_PATH = "/_ecg"

    attr_reader :mounted_path

    def initialize(app, options={})
      @app = app
      @mounted_path = options.delete(:mounted_path) || DEFAULT_MOUNTED_PATH
    end

    def call(env)
      request = Rack::Request.new(env)
      if request.path_info == mounted_path
        [200, {"X-Rack-ECG-Version" => Rack::ECG::VERSION}, ["Rack::ECG"]]
      else
        @app.call(env)
      end
    end
  end
end
