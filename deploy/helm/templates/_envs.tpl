{{/* vim: set filetype=mustache: */}}
{{/*
Environment variables for web and worker containers
*/}}
{{- define "app.envs" }}
env:
  - name: POSTGRES_USER
    valueFrom:
      secretKeyRef:
        name: rds-instance-output
        key: database_username
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: rds-instance-output
        key: database_password
  - name: POSTGRES_HOST
    valueFrom:
      secretKeyRef:
        name: rds-instance-output
        key: rds_instance_address
  {{- if eq .Values.deploy.settings__sentry__environment "uat" }}
  - name: POSTGRES_DATABASE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: database_name
  {{ else }}
  - name: POSTGRES_DATABASE
    valueFrom:
      secretKeyRef:
        name: rds-instance-output
        key: database_name
  {{ end }}
  - name: AWS_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
        name: s3
        key: access_key_id
  - name: AWS_SECRET_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: s3
        key: secret_access_key
  - name: AWS_BUCKET
    valueFrom:
      secretKeyRef:
        name: s3
        key: bucket_name
  - name: SECRET_KEY_BASE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: secretKeyBase
  - name: SETTINGS__SENTRY__DSN
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__sentry__dsn
  - name: SETTINGS__SENTRY__ENVIRONMENT
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__sentry__environment
  - name: SETTINGS__SIDEKIQ__USERNAME
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__sidekiq__username
  - name: SETTINGS__SIDEKIQ__WEB_UI_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__sidekiq__web_ui_password
  - name: SETTINGS__ENVIRONMENT
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__environment
  - name: SETTINGS__CREDENTIALS__USE_CASE_ONE__DESCRIPTION
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_one__description
  - name: SETTINGS__CREDENTIALS__USE_CASE_ONE__HOST
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_one__host
  - name: SETTINGS__CREDENTIALS__USE_CASE_ONE__HMRC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_one__hmrc_client_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_ONE__HMRC_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_one__hmrc_client_id
  - name: SETTINGS__CREDENTIALS__USE_CASE_ONE__HMRC_TOTP_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_one__hmrc_totp_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_TWO__DESCRIPTION
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_two__description
  - name: SETTINGS__CREDENTIALS__USE_CASE_TWO__HOST
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_two__host
  - name: SETTINGS__CREDENTIALS__USE_CASE_TWO__HMRC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_two__hmrc_client_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_TWO__HMRC_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_two__hmrc_client_id
  - name: SETTINGS__CREDENTIALS__USE_CASE_TWO__HMRC_TOTP_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_two__hmrc_totp_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_THREE__DESCRIPTION
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_three__description
  - name: SETTINGS__CREDENTIALS__USE_CASE_THREE__HOST
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_three__host
  - name: SETTINGS__CREDENTIALS__USE_CASE_THREE__HMRC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_three__hmrc_client_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_THREE__HMRC_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_three__hmrc_client_id
  - name: SETTINGS__CREDENTIALS__USE_CASE_THREE__HMRC_TOTP_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_three__hmrc_totp_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_FOUR__DESCRIPTION
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_four__description
  - name: SETTINGS__CREDENTIALS__USE_CASE_FOUR__HOST
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_four__host
  - name: SETTINGS__CREDENTIALS__USE_CASE_FOUR__HMRC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_four__hmrc_client_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_FOUR__HMRC_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_four__hmrc_client_id
  - name: SETTINGS__CREDENTIALS__USE_CASE_FOUR__HMRC_TOTP_SECRET
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__credentials__use_case_four__hmrc_totp_secret
  {{- if eq .Values.deploy.settings__environment "non-live" }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__FIRST_NAME
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_one__first_name
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__LAST_NAME
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_one__last_name
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__NINO
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_one__nino
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__DOB
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_one__dob
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__START_DATE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_one__start_date
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__END_DATE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_one__end_date
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__CORRELATION_ID
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_one__correlation_id
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__FIRST_NAME
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_two__first_name
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__LAST_NAME
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_two__last_name
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__NINO
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_two__nino
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__DOB
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_two__dob
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__START_DATE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_two__start_date
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__END_DATE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_two__end_date
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__CORRELATION_ID
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_two__correlation_id
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__FIRST_NAME
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_three__first_name
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__LAST_NAME
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_three__last_name
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__NINO
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_three__nino
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__DOB
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_three__dob
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__START_DATE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_three__start_date
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__END_DATE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_three__end_date
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__CORRELATION_ID
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_three__correlation_id
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__FIRST_NAME
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_four__first_name
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__LAST_NAME
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_four__last_name
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__NINO
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_four__nino
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__DOB
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_four__dob
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__START_DATE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_four__start_date
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__END_DATE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_four__end_date
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__CORRELATION_ID
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: settings__smoke_test__use_case_four__correlation_id
  {{ end }}
  - name: REDIS_URL
    valueFrom:
      secretKeyRef:
        name: elasticache
        key: redis_url
  - name: RAILS_ENV
    value: production
  - name: RAILS_LOG_TO_STDOUT
    value: 'true'
  - name: HOST
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: deployHost
{{- end }}
