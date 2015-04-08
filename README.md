# Rack::ECG

Rack middleware for Ruby web apps to provide a simple health check endpoint to tell
you vital life signs from inside your app.

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

**`checks`** - out of the box `Rack::ECG` doesn't do much and just checks that
HTTP responses can be returned. There are a number of built in checks that
`Rack::ECG` can be told to do (more to come)
- `:git_revision` - this assumes your code is deployed via git and exists in a
  git repo, and that the `git` command can access it
- `:migration_version` - this assumes you are using ActiveRecord migrations. It
  queries the `schema_versions` table and tells you what version the database is
at.

So using `git_revision` and `migration_version` would look like:

```ruby
use Rack::ECG, checks: [:git_revision, :migration_version]
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
  }
}
```

**`at`** - by default `Rack::ECG` is mapped to a URL of `/_ecg`, you can set this to
a different path by setting the `at` option. e.g.

```ruby
use Rack::ECG, at: "/health_check"
```


# Contributing

1. Fork it ( https://github.com/[my-github-username]/rack-ecg/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
