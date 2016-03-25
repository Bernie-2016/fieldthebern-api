# Field the Bern - API

Rails API for crowdsourced voter canvassing.

## Development

### Prerequisites

* git
* ruby 2.2.3 ([rvm](https://rvm.io) recommended)
* [postgres](http://www.postgresql.org/) (`brew install postgres` on OSX)

### Setup

1. Clone the repository (`git clone git@github.com:Bernie-2016/fieldthebern-api.git`)
2. Obtain an oauth access token for `ngp_van` from a team member in Slack.
3. Configure the project locally: `bundle config --local GITHUB_OAUTH_TOKEN <token>:x-oauth-basic`
4. Install gem dependencies: `bundle install`
5. Create and migrate the database: `rake db:setup`
6. Copy `.env.sample` to `.env`. Create test apps with the relevant services to get credentials.
7. Run `gem install foreman` to install the foreman gem, used for running Procfile-based apps.
8. Run `foreman start` to start the server.

### Testing
`http://api.lvh.me:5000/ping`

You must set `ENV['MIN_INTERVAL_BETWEEN_VISITS_HOURS']` to at least `1` for specs to pass.

## API Error Format

```json
{
  "errors": [
    {
      "id": "DASHERIZED_CAPITALIZED_ERROR_NAME",
      "title": "User friendly error name",
      "detail": "Value of Error.message",
      "status": "HTTP_CODE_IN_INTEGER_FORMAT"
    }
  ]
}
```

This format is consistent with the JSON API specification for errors. The root object should be called "errors". It should be an array, even if it's just a single error, which is our case.

[JSON API spec for errors](http://jsonapi.org/format/#errors)

## Contributing

1. Fork it ( https://github.com/Bernie-2016/fieldthebern-api/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## License

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0)
