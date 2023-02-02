# Testing
## Stand-alone test

A method exists to run a single test on a given use_case, it is used internally by the smoke tests

It can be run from a rails console with
```ruby
TestSubmission.call(
  'one', # required use_case
  first_name: 'first',
  last_name: 'name',
  nino: 'QQ123456C',
  dob: '1990-01-01',
  start_date: '2021-01-01',
  end_date: '2021-03-31'
)
```
As long as the current dev/uat environment has the correct use case one configuration in settings a series of calls will be made to obtain, format and display the pre-created sandbox data

## Smoke tests
There are endpoints available for each of the use_cases on non-live environments e.g.
```http
http://localhost:3000/smoke-test/one
```

that will run a smoke test against the sandbox environment

You can also trigger them manually from a rails console using

```ruby
SmokeTest.call(:two)
```

By design, this will only output true or false, so as not to leak any sandbox data

Successful results are stored for 1 hour, to ensure that stale successes don't get reported, and a summary is accessible at
```http
https://HOST/smoke-test
```
That will echo the recently successful test outcomes


## Test HMRC Sandbox data


### Local setup

- copy `.env.sample` to `.env.development`. It will be gitignored!

```shell
cp .env.sample .env.development
```

- Place the SETTINGS for secrets required for each use case in `.env.development`. *see `values-uat.yml`!*

> **WARNING**
> Do not use production secrets as this could/would breach our memorandum of understanding!


### Execute a test

Each use case's endpoint can be called using the rails console

```ruby

SmokeTest.call(:one)
=> true  # <-- success
SmokeTest.call(:one)
=> false # <-- failure
```

### How to fix a failing smoke test
Smoke tests can fail if HMRC change data in their sandbox, including that created by us. To fix you can either create new data (not discussed here) or extract the data from the sandbox and update our tests to expect it.


> **NOTE**
> The data in the sandbox is only as realistic as we make it. It merely returns whatever data we have created following [their guides](https://developer.service.hmrc.gov.uk/).

#### Extract actual response received from the HMRC sandbox for an existing smoke test

 - setup the repo to run locally using UAT secrets (see [Local setup](#local-setup))
 - amend the `SmokeTest.call` method to `puts` the response (puts generates minified JSON)

```ruby
  def call
    puts actual_response # <-- add this line
    actual = JSON.parse(actual_response)["data"]
    expected = JSON.parse(expected_response)["data"]
    ...
```

 - run a rails console and exeute the smoke test
 ```ruby
 $ rails console
 > SmokeTest.call(:one)
 =>
 {"some_minified_json":"values"}
 false
 ```

 - copy the output to the relevant `spec/fixtures/smoke_tests/use_case_<number>.json` file.

 - rerunning the smoke test in the console should now pass (return true)

 - remove the `puts` command, commit, push and open a PR

### How to add new HMRC data for smoke tests

#### Create new test user or use existing one

The existing HMRC sandbox test user used in the smoke tests has their details in specified in the `values-uat-yaml` file. Alternatively you can create a new HMRC sandbox test "individual" using the [HMRC developer hub API or UI](https://developer.service.hmrc.gov.uk/api-test-user) - see [Creating HMRC sandbox test data](https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/4295328084/Creating+HMRC+sandbox+test+data) for more.

 Once you have a test individual you can retrieve their details, append paye income and append paye employments using the convenience classes namespaced to `HMRC::Sandbox::`. You will need to follow [Local setup](#local-setup) steps first!


```ruby
# retrieve and append data to existing sandbox user
jimbob = HMRC::Sandbox::Individual.new("Jim", "Bob", "1951-01-02", "XX123456X")
data_for_individual = HMRC::Sandbox::DataForIndividual.new(individual: jimbob, use_case: :one, start_date: "2022-10-01".to_date, end_date: "2022-12-31".to_date)
data_for_individual.retrieve
data_for_individual.append_paye
data_for_individual.retrieve # <-- you should see the appended paye
data_for_individual.append_employment
data_for_individual.retrieve # <-- you should see the appended employment
```

#### Notes on data creation
- For paye please note the HMRC developer hub comment
 > the `paymentDate` value provided in the POST body will be used to determine if
the PAYE data sits within the date range provided in the query parameters,
if they do not then the PAYE data will not be returned" HMRC developer documentation
- When adding employments please not that they are per individual and therefore are retrieved in payloads irrespective of date ranges. Therefore adding employment will change payloads returned using any endpoint (use case one to four) for that individual and so may break smoke tests.
