# Connecting to the hosted service

There are 3 hosted services available, UAT, staging and production.  
* UAT and staging talk to the HMRC sandbox and contain fake users and fake, uploaded by us, data.  
* Production talks to the live HMRC APIs

UAT is accessible from any computer, whereas staging and production require the use of the MOJ - DSD VPN to connect

To request any/all of the following:
* a set of credentials for any of these instances 
* the list of user values that will return data for the non-production hosted instances

visit the #laa-hmrc-interface slack channel and drop us a message

## Requesting data from the service
Examples in this section will be made to localhost and only contain fake data, you will need to update this when calling your chosen target environment

You will need to request a bearer token from your target environment
```shell
curl -F grant_type=client_credentials \
-F client_id=10000000-0000-0000-0000-000000000001 \
-F client_secret=00000000-1111-2222-3333-000000000000 \
-X POST http://localhost:4050/oauth/token
```
Which should return a response like
```json
{
  "access_token":"BSj8EmiuxwI1Z699CBY5_qnPxH6wq_nw1M3ZGK_wImg",
  "token_type":"Bearer",
  "expires_in":7200,
  "created_at":1635240555
}
```

You should then submit a submission by POSTing to the `/api/v1/submission/create/{use_case}` endpoint
with your requested data as escaped JSON in the body, e.g.
```shell
curl  -X POST "http://localhost:4050/api/v1/submission/create/one" \ 
      -H  "accept: */*" \
      -H  "Authorization: Bearer <your-bearer-token-from-previous-step>" \
      -H  "Content-Type: application/json" \
      -d "{\"filter\":{\"first_name\":\"Langley\",\"last_name\":\"Yorke\",\"nino\":\"MN212451D\",\"dob\":\"1992-07-22\",\"start_date\":\"2020-08-01\",\"end_date\":\"2020-10-01\"}}"
```
Which, on success, should return:
```json
{
  "id":"a6c1785d-1e43-460a-a943-1a1fd94058a0",
  "_links": [
    {
      "href":"http://localhost:4050/api/v1/submission/status/a6c1785d-1e43-460a-a943-1a1fd94058a0"
    }
  ]
}
```

See the swagger docs for more detail and a testable interface
