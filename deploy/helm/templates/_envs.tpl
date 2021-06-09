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
  - name: POSTGRES_DATABASE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: database_name
  - name: SECRET_KEY_BASE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: secretKeyBase
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
