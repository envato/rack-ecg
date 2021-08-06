# Rack::ECG

[![Gem version](https://img.shields.io/gem/v/rack-ecg)][gem-page] [![Rubydoc](https://img.shields.io/badge/docs-rubydoc-success)][rubydoc]

Rack middleware for Ruby web apps, providing a simple and extensible health
check endpoint, with minimal configuration.

> Electrocardiogram (ECG): A recording of the electrical activity of the heart.

## Features

- Start with a single line in your `config.ru` or `config/application.rb` file.
- reports git revision status
- reports ActiveRecord migration schema version
- reports errors if any check can't be executed for whatever reason
- JSON output

## Development Status

[![Build Status](https://github.com/envato/rack-ecg/workflows/test/badge.svg?branch=main)](https://github.com/envato/rack-ecg/actions?query=branch%3Amain)

`Rack::ECG` is extracted from production code in use at
[Envato](http://envato.com). However, it is undergoing early development, and
APIs and features are almost certain to be in flux.

## Getting Started

Add this to your application's `Gemfile`:

```ruby
gem 'rack-ecg', '~> 0.1.0`
```

Then run `bundle install`.

In Rails you can add `Rack::ECG` to your `config/application.rb` as a middleware:

```ruby
# config/application.rb
# ...
config.middleware.use Rack::ECG
# ...
```

In Rack apps, you can add `Rack::ECG` to your `config.ru`:

```ruby
# config.ru
require 'rack/ecg'

use Rack::ECG

run MyRackApp
```

## Usage

You can now hit your app and get a basic health check response from `Rack::ECG`

```
$ curl http://localhost:9292/_ecg
{
  "http": {
    "status": "ok",
    "value": "online"
  }
}
```

`/_ecg` will return a `200` HTTP status if all the checks are OK, or `500`
status if any of the checks fail.


## Configuration

There are options that can be passed to `use Rack::ECG` to customise how it works.

### Checks

By default, `Rack::ECG` indicates that the service is reponsive via a `http` check. Additional checks are included in this gem, and can be enabled by passing their configuration to the `checks` parameter. To enable a check, add its name, and optionally configuration, to the `checks` array:

```ruby
use Rack::ECG, checks: [
  # no configuration required, or allowed
  :http,
  # passing configuration options
  [:static, { name: "app", value: "my-cool-app" }],
  # some checks can be used multiple times
  [:static, { name: "env", value: Rails.env }],
]
```

#### `active_record`

Requires a configured ActiveRecord connection. Does not support configuration. Indicates whether the connection to the default database is currently open. On success, returns something in the following format:

```json
{
  "active_record": {
    "status": "ok",
    "value": true
  }
}
```

#### `error`

Does not support configuration. Always returns the following:

```json
{
  "error": {
    "status": "error",
    "value": "PC LOAD ERROR"
  }
}
```

#### `git_revision`

Requires the `git` executable on path, and that the application's working directory is within a Git repository. Does not support configuration. On success, returns something in the following format:

```json
{
  "git_revision": {
    "status": "ok",
    "value": "dc840f9d5563e6e5a8b34da29c298764e3046039"
  }
}
```

#### `http`

Automatically included, and does not support configuration. Always returns the following:

```json
{
  "http": {
    "status": "ok",
    "value": "online"
  }
}
```

#### `migration_version`

Requires a configured ActiveRecord connection, and that ActiveRecord migrations are in use. Does not support configuration. Queries the `schema_versions` table on the default database to report the current migration version. On success, returns something in the following format:

```json
{
  "migration_version": {
    "status": "ok",
    "value": "20210506024055"
  }
}
```

#### `redis`

Requires a configured global Redis client. Does not support configuration. Indicates whether the global client is currently connected to the Redis database. On success, returns something in the following format:

```json
{
  "redis": {
    "status": "ok",
    "value": true
  }
}
```

#### `sequel`

Requires the Sequel gem. Requires configuration, and can be configured multiple times. Indicates whether a (new) connection can be established to the configured Sequel database.

Given the following configuration:

```ruby
{
  connection: "sqlite://events.db",
  name: "events", # must be unique per sequel check
}
```

Returns the something in the following format on success:

```json
{
  "sequel_events": {
    "status": "ok",
    "value": true
  }
}
```

#### `static`

Returns the same value every time. Requires configuration, and can be configured multiple times.

Given the following configuration:

```ruby
{
  name: "image_build_url",               # must be unique per static check
  success: true,                         # default value
  status: Rack::ECG::Check::Status::OK,  # optional, overrides `success`
  value: ENV["IMAGE_BUILD_URL"], 
}
```

Returns the something in the following format:

```json
{
  "image_build_url": {
    "status": "ok",
    "value": "https://example.com/pipelines/my-cool-app/builds/1234"
  }
}
```

### `at`

By default `Rack::ECG` is mapped to a URL of `/_ecg`, you can set this to
a different path by setting the `at` option. e.g.

```ruby
use Rack::ECG, at: "/health_check"
```

### `hook`

The `hook` option takes a `Proc` or equivalent, and calls it after the checks
have run, but before the response is complete.

```ruby
use Rack::ECG, hook: Proc.new { |success, _checks| puts "Is healthy? #{success}" }
```

- `success`: whether the response will indicate success
- `checks`: an array of the check names and values

More examples are provided in [/examples](https://github.com/envato/rack-ecg/tree/main/examples)

## Requirements

- Ruby >= 2.5
- Rack
- To use optional `git_revision` check, your deployed code needs to be in a git repo, and
`git` command must be accessible on the server
- To use optional `migration_version` check, you must be using ActiveRecord and
migrations stored in `schema_versions` table

## Contact

- [github project](https://github.com/envato/rack-ecg)
- [gitter chat room ![Join the chat at
  https://gitter.im/envato/rack-ecg](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/envato/rack-ecg)
- Bug reports and feature requests are via [github issues](https://github.com/envato/rack-ecg/issues)

## Maintainers

- [Liam Dawson](https://github.com/liamdawson)

## Contributors

- [Tao Guo](https://github.com/taoza)
- [Julian Doherty](https://github.com/madlep)
- [Warren Seen](https://github.com/warrenseen)

## License

`Rack::ECG` uses MIT license. See
[`LICENSE.txt`](https://github.com/envato/rack-ecg/blob/main/LICENSE.txt) for
details.

## Code of conduct

We welcome contribution from everyone. Read more about it in
[`CODE_OF_CONDUCT.md`](https://github.com/envato/rack-ecg/blob/main/CODE_OF_CONDUCT.md)

## Contributing

For bug fixes, documentation changes, and small features:

1. Fork it ( https://github.com/[my-github-username]/rack-ecg/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

For larger new features: Do everything as above, but first also make contact with the project maintainers to be sure your change fits with the project direction and you won't be wasting effort going in the wrong direction.

## About

This project is maintained by the [Envato engineering team][webuild] and funded by [Envato][envato].

[<img src="http://opensource.envato.com/images/envato-oss-readme-logo.png" alt="Envato logo">][envato]

Encouraging the use and creation of open source software is one of the ways we serve our community. See [our other projects][oss] or [come work with us][careers] where you'll find an incredibly diverse, intelligent and capable group of people who help make our company succeed and make our workplace fun, friendly and happy.

  [webuild]: http://webuild.envato.com?utm_source=github
  [envato]: https://envato.com?utm_source=github
  [oss]: http://opensource.envato.com//?utm_source=github
  [careers]: http://careers.envato.com/?utm_source=github
  [gem-page]: https://rubygems.org/gems/rack-ecg
  [rubydoc]: https://www.rubydoc.info/gems/rack-ecg/
