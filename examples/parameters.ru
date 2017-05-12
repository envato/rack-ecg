require 'rack/ecg'
require 'sequel'
require 'sqlite3'

use Rack::ECG, checks: [
  :http,
  [:sequel, {connection: 'sqlite://events.db', name: 'events'}],
  [:sequel, {connection: 'sqlite://projections.db', name: 'projections'}]
]

run -> (env) { [200, {}, ["Hello, World"]] }
