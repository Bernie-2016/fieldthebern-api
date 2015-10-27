# Ground Game API

INFO ABOUT APP HERE

## Setup

get .env variables in a secure way and create .env file from the .env.sample file

`bundle install`

`gem install foreman`

`foreman start`

## Test
`http://api.lvh.me:5000/ping`

## API Error Format

```json
{
  errors: [{
    id: "DASHERIZED_CAPITALIZED_ERROR_NAME",
    title: "User friendly error name",
    detail: "Value of Error.message",
    status: HTTP_CODE_IN_INTEGER_FORMAT
  }]
}
```

This format is consistent with the JSON API specification for errors. The root object should be called "errors". It should be an array, even if it's just a single error, which is our case.

[JSON API spec for errors](http://jsonapi.org/format/#errors)