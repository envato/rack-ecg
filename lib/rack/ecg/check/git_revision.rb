module Rack
  class ECG
    module Check
      class GitRevision
        def result
          _stdin, stdout, stderr, wait_thread = Open3.popen3("git rev-parse HEAD")

          success = wait_thread.value.success?

          status = success ? "ok" : "error"

          value = success ? stdout.read : stderr.read
          value = value.strip

          Result.new(:git_revision, status, value)
        end
      end
    end
  end
end
