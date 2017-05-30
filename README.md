# Rack::ECG

[![Join the chat at https://gitter.im/envato/rack-ecg](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/envato/rack-ecg?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

An easy to configure Rack middleware for Ruby web apps to provide a simple
health check endpoint that tells you vital life signs about your app. All
without the boilerplate service checking code you've written 10 times before.

(it's ECG as in electrocardiogram - as in the machine that monitors how your
heart works)

## Features
- simple 1 line to drop into your `config.ru` or `config/application.rb` file to
  set up
- reports git revision status
- reports ActiveRecord migration schema version
- reports errors if any check can't be executed for whatever reason
- JSON output

## Development Status [![travis ci build](https://api.travis-ci.org/envato/rack-ecg.svg)](https://travis-ci.org/envato/rack-ecg)

`Rack::ECG` is extracted from production code in use at
[Envato](http://envato.com). However, it is undergoing early development, and
APIs and features are almost certain to be in flux.

## Getting Started

Add this line to your application's Gemfile:

```ruby
gem 'rack-ecg'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-ecg

### Rails

In Rails you can add `Rack::ECG` to your `config/application.rb` as a middleware

```ruby
# config/application.rb
# ...
config.middleware.use Rack::ECG
# ...
```

### Rack

In Rack apps, you can add `Rack::ECG` to your `config.ru`

```ruby
# config.ru
require 'rack/ecg'

use Rack::ECG

run MyRackApp
```

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

There are options that can be passed to `use Rack::ECG` to customise how it
works.

### `checks`
Out of the box `Rack::ECG` doesn't do much and just checks that
HTTP responses can be returned. There are a number of built in checks that
`Rack::ECG` can be told to do (more to come)
- `:git_revision` - this assumes your code is deployed via git and exists in a
  git repo, and that the `git` command can access it
- `:migration_version` - this assumes you are using ActiveRecord migrations. It
  queries the `schema_versions` table and tells you what version the database is
at.
- `:active_record` - this checks if an ActiveRecord connection is active.
- `:redis` - this checks if a Redis connection is active.

So using `git_revision`, `migration_version`, `active_record`, and `redis` would look like:

```ruby
use Rack::ECG, checks: [:git_revision, :migration_version, :active_record, :redis]
```

```
$ curl http://localhost:9292/_ecg
{
  "http": {
    "status": "ok",
    "value": "online"
  },
  "git_revision": {
    "status": "ok",
    "value": "fb16e2c3b88af671c42880e6977bba34d7b05ba6\n"
  },
  "migration_version": {
    "status": "ok",
    "value": "20150319050250"
  },
  "active_record": {
    "status": "ok",
    "value": "true"
  },
  "redis": {
    "status": "ok",
    "value": "true"
  }
}
```

#### Checks with parameters
Some checks, such as the `sequel` check, require a parameter hash. In this case, you must provide the check as a tuple consisting of both the check name, and a hash of parameters:

```ruby
use Rack::ECG, checks: [:http, [:sequel, {connection: "sqlite://my-sqlite.db"}]]
```

```
$ curl http://localhost:9292/_ecg
{
  "http": {
    "status": "ok",
    "value": "online"
  },
  "sequel": {
    "status": "ok",
    "value": "true"
  }
}
```

Because the `sequel` check operates on a per-connection basis, you can specify multiple Sequel databases to independently check, and provide a friendly name for disambiguation purposes:

```ruby
use Rack::ECG, checks: [
  :http,
  [:sequel, {connection: 'sqlite://events.db', name: 'events'}],
  [:sequel, {connection: 'sqlite://projections.db', name: 'projections'}]
]
```

```
$ curl http://localhost:9292/_ecg

{
  "http": {
    "status": "ok",
    "value": "online"
  },
  "sequel_events": {
    "status": "ok",
    "value": "true"
  },
  "sequel_projections": {
    "status": "ok",
    "value": "true"
  }
}
```

### `at`

By default `Rack::ECG` is mapped to a URL of `/_ecg`, you can set this to
a different path by setting the `at` option. e.g.

```ruby
use Rack::ECG, at: "/health_check"
```

More examples are provided in [/examples](https://github.com/envato/rack-ecg/tree/master/examples)

## Requirements
- Ruby >= 1.9.3 (this may be increased to Ruby >= 2.0 if it makes sense to use
  Ruby 2.0 features)
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

- [Tao Guo](https://github.com/taoza)
- [Warren Seen](https://github.com/warrenseen)

## Authors

- [Julian Doherty](https://github.com/madlep)
- [Warren Seen](https://github.com/warrenseen)

## License

`Rack::ECG` uses MIT license. See
[`LICENSE.txt`](https://github.com/envato/rack-ecg/blob/master/LICENSE.txt) for
details.

## Code of conduct

We welcome contribution from everyone. Read more about it in
[`CODE_OF_CONDUCT.md`](https://github.com/envato/rack-ecg/blob/master/CODE_OF_CONDUCT.md)

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
