# Swagger
## Functional documentation
To see the swagger implementation, you can access it on our
[staging environment](https://laa-hmrc-interface-staging.cloud-platform.service.justice.gov.uk)
when you have the MOJ VPN turned on

## API Documentation

We use [rswag](https://github.com/rswag/rswag) to document with [swagger](https://swagger.io/) the endpoints that are being exposed.

## Running it locally
To view the API documentation, start the rails server locally using `rails s` and then browse to http://localhost:3000/

To use the 'Try it out' functionality, you need to have first created an oAuth user in your local database, 
see [the development documentation](development.md#applications)

## Extending the API
To add a new endpoint, run `rails generate rspec:swagger <controller_name>` to generate a request spec.

## Re-generating the documentation
Add appropriate tests and content to the spec, then run `NOCOVERAGE=true rake rswag`.
The new endpoint should now appear in the Swagger UI interface.

**Note**: the `NOCOVERAGE` prefix is not strictly required but it will silence the coverage warnings.
As it only runs swagger test files the coverage will be well below the expected 100% 
