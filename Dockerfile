FROM ruby:4.0.6-alpine3.24

LABEL org.opencontainers.image.vendor="Ministry of Justice" \
      org.opencontainers.image.authors="Apply for civil legal aid team (apply-for-civil-legal-aid@digital.justice.gov.uk)" \
      org.opencontainers.image.title="LAA HMRC Interface Service API" \
      org.opencontainers.image.description="Wrapper API for accessing HRMC API for LAA use cases" \
      org.opencontainers.image.url="https://github.com/ministryofjustice/laa-hmrc-interface-service-api"

ENV RAILS_ENV production

RUN set -ex

# # zlib: upgrade zlib system libraries to address security vulnerability in ruby bundled zlib gem
# # TODO: Can be removed once alpine image contains zlib version 1.3.2-r0
RUN apk upgrade --no-cache zlib

RUN apk --no-cache add --virtual build-dependencies \
                    build-base \
                    zlib-dev \
                    postgresql-dev \
                    yaml-dev \
&& apk --no-cache add postgresql-client \
                    gcompat

RUN mkdir /app
WORKDIR /app

RUN adduser --disabled-password apply -u 1001

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY .ruby-version /app/.ruby-version

RUN gem update --system
RUN bundle config set --local without 'test development' && bundle install


COPY . /app

RUN apk del build-dependencies

EXPOSE 3000

RUN chown -R apply:apply /app

#RUN chmod +x ./bin/uat_deploy

# expect ping environment variables
# TODO: remove
ARG BUILD_DATE
ARG BUILD_TAG
ARG APP_BRANCH

# set ping environment variables
# TODO: remove
ENV BUILD_DATE=${BUILD_DATE}
ENV BUILD_TAG=${BUILD_TAG}
ENV APP_BRANCH=${APP_BRANCH}

# set ping environment variables for status controller
ARG APP_BUILD_DATE
ENV APP_BUILD_DATE=${APP_BUILD_DATE}
ARG APP_BUILD_TAG
ENV APP_BUILD_TAG=${APP_BUILD_TAG}
ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT=${APP_GIT_COMMIT}
ARG APP_BRANCH
ENV APP_BRANCH=${APP_BRANCH}


# allow public files to be served
ENV RAILS_SERVE_STATIC_FILES true

USER 1001

CMD "./docker_scripts/run"
