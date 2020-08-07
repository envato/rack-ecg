# frozen_string_literal: true
module Rack
  class ECG
    module Check
      # @!method initialize
      #   Returns the SHA1 of the current commit, as reported by the git
      #   executable.
      class GitRevision
        def result
          _stdin, stdout, stderr, wait_thread = Open3.popen3("git rev-parse HEAD")

          success = wait_thread.value.success?

          status = success ? Status::OK : Status::ERROR

          value = success ? stdout.read : stderr.read
          value = value.strip

          Result.new(:git_revision, status, value)
        end
      end

      CheckRegistry.instance.register(:git_revision, GitRevision)
    end
  end
end
