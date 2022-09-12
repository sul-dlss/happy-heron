FROM ruby:3.1-alpine

# postgresql-client is required for invoke.sh
RUN apk add --update --no-cache \
  build-base \
  postgresql-dev \
  postgresql-client \
  tzdata \
  yarn \
  git

# Get bundler 2.0
RUN gem install bundler

ARG UID=1000
ARG GID=1000
RUN addgroup -g $GID h2
RUN adduser -G h2 -u $UID -D h2

WORKDIR /app

COPY Gemfile Gemfile.lock package.json yarn.lock ./

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV BUNDLE_WITHOUT="test:development"

RUN bundle install
RUN yarn install

COPY --chown=h2:h2 . .
USER h2:h2

RUN bin/rails assets:precompile

CMD bin/puma -C config/puma.rb config.ru 2>&1 | tee -a log/production.log
