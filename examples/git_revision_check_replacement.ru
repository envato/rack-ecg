# frozen_string_literal: true
require "rack/ecg"

# This example behaves just like the deprecated GitRevision check, except that the value is memoized.
#   i.e. "Fetching the git revision" shouldn't show up for every `GET /_ecg` request.
#
# Also consider writing the git revision to a file, or storing it in an environment variable, so it can found more
# efficiently and with fewer dependencies.

def git_revision
  puts "Fetching the git revision"

  _stdin, stdout, stderr, wait_thread = Open3.popen3("git rev-parse HEAD")

  success = wait_thread.value.success?

  status = success ? Rack::ECG::Check::Status::OK : Rack::ECG::Check::Status::ERROR

  value = success ? stdout.read : stderr.read
  value = value.strip

  { name: :git_revision, status: status, value: value }
end

use(Rack::ECG, { checks: [[:static, git_revision]] })

run(-> (_env) { [200, {}, ["Hello, World"]] })
