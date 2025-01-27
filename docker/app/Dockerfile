# This Dockerfile is optimized for running in development. That means it trades
# build speed for size. If we were using this for production, we might instead
# optimize for a smaller size at the cost of a slower build.
FROM ruby:3.4.1-bookworm

RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash -

# postgresql-client is required for invoke.sh
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends \
      postgresql-client postgresql-contrib libpq-dev \
      libxml2-dev clang git tzdata nodejs

# Get bundler 2.0
RUN gem install bundler

WORKDIR /app

RUN npm install -g yarn

COPY Gemfile Gemfile.lock package.json yarn.lock ./

RUN bundle config set without 'production' && \
  bundle install && \
  yarn install

COPY . .

RUN bin/rails assets:precompile

CMD ["./docker/app/invoke.sh"]
