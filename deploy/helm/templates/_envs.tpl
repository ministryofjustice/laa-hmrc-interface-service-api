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
    value: {{ .Values.database.name | quote }}
  {{ else }}
  - name: POSTGRES_DATABASE
    valueFrom:
      secretKeyRef:
        name: rds-instance-output
        key: database_name
  {{ end }}
  - name: AWS_BUCKET
    valueFrom:
      secretKeyRef:
        name: s3
        key: bucket_name
  - name: SECRET_KEY_BASE
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: secretKeyBase
  - name: SETTINGS__SENTRY__DSN
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__sentry__dsn
  - name: SETTINGS__SIDEKIQ__USERNAME
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__sidekiq__username
  - name: SETTINGS__SIDEKIQ__WEB_UI_PASSWORD
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__sidekiq__web_ui_password
  - name: SETTINGS__CREDENTIALS__USE_CASE_ONE__DESCRIPTION
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_one__description
  - name: SETTINGS__CREDENTIALS__USE_CASE_ONE__HOST
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_one__host
  - name: SETTINGS__CREDENTIALS__USE_CASE_ONE__HMRC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_one__hmrc_client_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_ONE__HMRC_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_one__hmrc_client_id
  - name: SETTINGS__CREDENTIALS__USE_CASE_ONE__HMRC_TOTP_SECRET
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_one__hmrc_totp_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_TWO__DESCRIPTION
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_two__description
  - name: SETTINGS__CREDENTIALS__USE_CASE_TWO__HOST
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_two__host
  - name: SETTINGS__CREDENTIALS__USE_CASE_TWO__HMRC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_two__hmrc_client_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_TWO__HMRC_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_two__hmrc_client_id
  - name: SETTINGS__CREDENTIALS__USE_CASE_TWO__HMRC_TOTP_SECRET
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_two__hmrc_totp_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_THREE__DESCRIPTION
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_three__description
  - name: SETTINGS__CREDENTIALS__USE_CASE_THREE__HOST
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_three__host
  - name: SETTINGS__CREDENTIALS__USE_CASE_THREE__HMRC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_three__hmrc_client_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_THREE__HMRC_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_three__hmrc_client_id
  - name: SETTINGS__CREDENTIALS__USE_CASE_THREE__HMRC_TOTP_SECRET
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_three__hmrc_totp_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_FOUR__DESCRIPTION
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_four__description
  - name: SETTINGS__CREDENTIALS__USE_CASE_FOUR__HOST
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_four__host
  - name: SETTINGS__CREDENTIALS__USE_CASE_FOUR__HMRC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_four__hmrc_client_secret
  - name: SETTINGS__CREDENTIALS__USE_CASE_FOUR__HMRC_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_four__hmrc_client_id
  - name: SETTINGS__CREDENTIALS__USE_CASE_FOUR__HMRC_TOTP_SECRET
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: settings__credentials__use_case_four__hmrc_totp_secret
  {{- if eq .Values.deploy.settings__environment "non-live" }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__FIRST_NAME
    value: {{ .Values.smoke_test.use_case_one.first_name | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__LAST_NAME
    value: {{ .Values.smoke_test.use_case_one.last_name | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__NINO
    value: {{ .Values.smoke_test.use_case_one.nino | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__DOB
    value: {{ .Values.smoke_test.use_case_one.dob | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__START_DATE
    value: {{ .Values.smoke_test.use_case_one.start_date | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__END_DATE
    value: {{ .Values.smoke_test.use_case_one.end_date | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_ONE__CORRELATION_ID
    value: {{ .Values.smoke_test.use_case_one.correlation_id | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__FIRST_NAME
    value: {{ .Values.smoke_test.use_case_two.first_name | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__LAST_NAME
    value: {{ .Values.smoke_test.use_case_two.last_name | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__NINO
    value: {{ .Values.smoke_test.use_case_two.nino | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__DOB
    value: {{ .Values.smoke_test.use_case_two.dob | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__START_DATE
    value: {{ .Values.smoke_test.use_case_two.start_date | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__END_DATE
    value: {{ .Values.smoke_test.use_case_two.end_date | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_TWO__CORRELATION_ID
    value: {{ .Values.smoke_test.use_case_two.correlation_id | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__FIRST_NAME
    value: {{ .Values.smoke_test.use_case_three.first_name | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__LAST_NAME
    value: {{ .Values.smoke_test.use_case_three.last_name | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__NINO
    value: {{ .Values.smoke_test.use_case_three.nino | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__DOB
    value: {{ .Values.smoke_test.use_case_three.dob | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__START_DATE
    value: {{ .Values.smoke_test.use_case_three.start_date | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__END_DATE
    value: {{ .Values.smoke_test.use_case_three.end_date | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_THREE__CORRELATION_ID
    value: {{ .Values.smoke_test.use_case_three.correlation_id | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__FIRST_NAME
    value: {{ .Values.smoke_test.use_case_four.first_name | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__LAST_NAME
    value: {{ .Values.smoke_test.use_case_four.last_name | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__NINO
    value: {{ .Values.smoke_test.use_case_four.nino | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__DOB
    value: {{ .Values.smoke_test.use_case_four.dob | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__START_DATE
    value: {{ .Values.smoke_test.use_case_four.start_date | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__END_DATE
    value: {{ .Values.smoke_test.use_case_four.end_date | quote }}
  - name: SETTINGS__SMOKE_TEST__USE_CASE_FOUR__CORRELATION_ID
    value: {{ .Values.smoke_test.use_case_four.correlation_id | quote }}
  - name: TEST_OAUTH_ACCOUNTS_JSON
    valueFrom:
      secretKeyRef:
        name: hmrc-interface-secrets
        key: test_oauth_accounts_json
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
  - name: SETTINGS__ENVIRONMENT
    value: {{ .Values.deploy.settings__environment | quote }}
  - name: SETTINGS__SENTRY__ENVIRONMENT
    value: {{ .Values.deploy.settings__sentry__environment | quote }}
  - name: HOST
    value: {{ .Values.deploy.host | quote }}
{{- end }}
