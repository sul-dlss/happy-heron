FROM ruby:3.1-alpine

# curl is to install supercronic
# postgresql-client and redis is required for invoke.sh
RUN apk add --update --no-cache \
  build-base \
  postgresql-dev \
  postgresql-client \
  tzdata \
  yarn \
  curl \
  redis

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.1/supercronic-linux-amd64
ENV SUPERCRONIC=supercronic-linux-amd64
ENV SUPERCRONIC_SHA1SUM=d7f4c0886eb85249ad05ed592902fa6865bb9d70

# Cron replacement, since cron must be run as root
RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Get bundler 2.0
RUN gem install bundler

ARG UID=1000
ARG GID=1000
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

RUN addgroup -g $GID h2
RUN adduser -G h2 -u $UID -D h2

WORKDIR /app

COPY Gemfile Gemfile.lock package.json yarn.lock ./

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV BUNDLE_WITHOUT="test:development:deployment"
ENV NODE_ENV=production

RUN bundle install
RUN yarn install

RUN chown -R h2:h2 /app
COPY --chown=h2:h2 . .
USER h2:h2

RUN bin/rails assets:precompile
# Write out the crontab file
RUN sh -c 'bundle exec whenever . | tee -a config/crontab'

CMD bin/puma -C config/puma.rb config.ru 2>&1 | tee -a log/production.log
