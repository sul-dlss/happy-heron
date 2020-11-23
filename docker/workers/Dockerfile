# This Dockerfile is optimized for running in development. That means it trades
# build speed for size. If we were using this for production, we might instead
# optimize for a smaller size at the cost of a slower build.
FROM ruby:2.7.2-alpine

# postgresql-client is required for invoke.sh
RUN apk add --update --no-cache \
  build-base \
  postgresql-dev \
  postgresql-client \
  redis \
  tzdata

# Get bundler 2.0
RUN gem install bundler

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle config set without 'production' && \
  bundle install

COPY . .

CMD ["./docker/workers/invoke.sh"]
