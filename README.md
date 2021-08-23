[![Maintainability](https://api.codeclimate.com/v1/badges/a3004dc77c88767725a8/maintainability)](https://codeclimate.com/github/ministryofjustice/laa-hmrc-interface-service-api/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a3004dc77c88767725a8/test_coverage)](https://codeclimate.com/github/ministryofjustice/laa-hmrc-interface-service-api/test_coverage)

# LAA-HMRC Interface Service API

This Service facilitates the HMRC API access for the LAA Use Cases

## Development 
### Dependencies
* Ruby 3
* Rails 6.1.x API

### System Dependencies
* postgres 

### Initial setup
* Clone the repo
* Copy the `.env` values from LastPass 
* Run `bundle install`
* Run the tests with `bundle exec rspec`
* Run the server with `bundle exec rails s`

### Stand-alone test

A test script has been added to run a single test on use_case one
It can be run from a rails console with 
```ruby 
ApplyGetTest.call(
  first_name: 'first', 
  last_name: 'name', 
  nino: 'QQ123456C', 
  dob: '1990-01-01', 
  start_date: '2021-01-01', 
  end_date: '2021-03-31'
)
```

As long as the current dev/uat environment has the correct use case one configuration in settings a series of calls will be made to obtain, format and display the pre-created sandbox data

### Smoke tests
There are endpoints available for each of the use_cases on non-live environments e.g. 
```http request
http://localhost:3000/smoke-test/one
```
that will run a smoke test against the sandbox environment

You can also trigger them manually from a rails console using

```ruby
SmokeTest.call(:two)
```

By design, this will only output true or false, so as not to leak any sandbox data

Successful results are stored for 1 hour, to ensure that stale successes don;t get reported, and a summary is accessible at
```http request
https://HOST/smoke-test
```
That will show echo the recently successful tests

### Documentation

We use [rswag](https://github.com/rswag/rswag) to document with [swagger](https://swagger.io/) the endpoints that are being exposed.

To view the API documentation, start the rails server locally using `rails s` and then browse to http://localhost:3000/api-docs/index.html.

To use the 'Try it out' functionality, you need to have first created an oAuth user in your local database

To add a new endpoint, run `rails generate rspec:swagger <controller_name>` to generate a request spec. 
Add appropriate tests and content to the spec, then run `NOCOVERAGE=true rake rswag`.
The new endpoint should now appear in the Swagger UI interface.

**Note**: the `NOCOVERAGE` prefix is not strictly required but it will silence the coverage warnings. 
As it only runs swagger test files the coverage will be well below the expected 100% 
