[![Ministry of Justice Repository Compliance Badge](https://github-community.service.justice.gov.uk/repository-standards/api/laa-hmrc-interface-service-api/badge)](https://github-community.service.justice.gov.uk/repository-standards/laa-hmrc-interface-service-api) 

# LAA-HMRC Interface Service API

This Service facilitates the HMRC API access for the LAA Use Cases

## Development

### Dependencies

- Ruby 3.4.7+
- Rails 8.0.x API

### System Dependencies

- postgres
- redis

### Setup

1. Copy the `.env` file from 1Password (hint: search `hmrc interface env`) and paste them into a new file called `.env.development`

2. Retrieve values for the .env file envvars from AWS console or k8s secrets. You will, at least, need the `TEST_OAUTH_ACCOUNTS_JSON` to seed your database with doorkeeper accounts.

3. Run the setup binstub

```sh
bin/setup
```

### Further reading

- Developer looking to use the API? - [Click here](docs/development.md)
- Looking for info on how the tests work? - [Click here](docs/testing.md)
- Want to read the API documentation? - [Click here](docs/swagger.md)
- Want to connect to the solution, local or hosted? - [Click here](docs/connect.md)
