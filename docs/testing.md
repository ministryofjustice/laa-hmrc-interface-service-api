# Testing
## Stand-alone test

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
>### *Deprecation warning*
> ApplyGetTest will be removed or renamed shortly as it no longer matches the original use

## Smoke tests
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

Successful results are stored for 1 hour, to ensure that stale successes don't get reported, and a summary is accessible at
```http request
https://HOST/smoke-test
```
That will echo the recently successful test outcomes
