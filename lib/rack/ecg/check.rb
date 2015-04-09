require "rack/ecg/check/git_revision"

module Rack
  class ECG
    module Check
      class Result < Struct.new(:name, :status, :value)
        def to_json
          {name => {:status => status, :value => value}}
        end
      end
    end
  end
end
