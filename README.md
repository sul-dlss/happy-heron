[![CircleCI](https://circleci.com/gh/sul-dlss/happy-heron.svg?style=svg)](https://circleci.com/gh/sul-dlss/happy-heron)
[![Maintainability](https://api.codeclimate.com/v1/badges/3dbc6311e79b7045bed4/maintainability)](https://codeclimate.com/github/sul-dlss/happy-heron/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/3dbc6311e79b7045bed4/test_coverage)](https://codeclimate.com/github/sul-dlss/happy-heron/test_coverage)

# Self-Deposit for the Stanford Digital Repository (SDR)

happy-heron, or H2 (from "Hydrus 2.0"), is a Rails web application enabling users to deposit scholarly content into the SDR. It will replace [Hydrus](https://github.com/sul-dlss/hydrus).

## UX Design

* Comps: https://projects.invisionapp.com/share/EQXC9CLKCR2
* Design Documentation: https://docs.google.com/document/d/1fcr2DYo7OrX-qTdeUOTWKSS1rlq_47sehESmbvgUsrk/edit

## Install Dependencies

Ruby dependencies can be installed with `bundle install`, JavaScript dependencies are installed via `yarn install`.

NOTE: H2 uses Ruby 2.7.2.

## Development

Start up dependencies with `docker compose up db redis` (with `-d` to run in background).

To run the H2 application in development mode, set `REMOTE_USER` because we aren't running behind Shibboleth, and set the `ROLES` environment variable to grant your fake user session administrative privileges:

```
gem install foreman
```

Then run the asset pipeline and webserver:
```shell
bin/dev
```

You can change user or roles by setting environment variables:
```shell
REMOTE_USER=auser@stanford.edu ROLES=dlss:hydrus-app-administrators bin/dev
```

## Testing

Start up dependencies with `docker compose up db` (with `-d` to run in background), then run tests with `bundle exec rspec`. If you also want to do style checks & linting, run Rubocop and RSpec serially via `bin/rake`.

### Integration

Spin up all docker compose services for local development and in-browser testing:

```shell
$ docker compose up # use -d to run in background
```

This will spin up the H2 web application, its background workers, and all service dependencies declared in docker-compose.yml.

#### Note: Requires Postgres

Before running `rake rails_rbi:all`, make sure the `db` docker compose service is running, else the type definitions for the app's models will be deleted.

## Deployment

H2 is deployed via Capistrano to servers running the Passenger server in standalone mode (as a systemd service rather than as an Apache module).

### Setup RabbitMQ
You must set up the durable rabbitmq queues that bind to the exchange where workflow messages are published.

```sh
RAILS_ENV=production bin/rake rabbitmq:setup
```
This is going to create queues for this application that bind to some topics.

### RabbitMQ queue workers
In a development environment you can start sneakers this way:
```sh
WORKERS=AssignPidJob,DepositStatusJob,RecordEmbargoReleaseJob bin/rake sneakers:run
```

but on the production machines we use systemd to do the same:
```sh
sudo /usr/bin/systemctl start sneakers
sudo /usr/bin/systemctl stop sneakers
sudo /usr/bin/systemctl status sneakers
```

This is started automatically during a deploy via capistrano

## Architecture

H2 uses the [SDR API](https://github.com/sul-dlss/sdr-api) to deposit collections and works (both files and metadata) into SDR.

H2 relies upon dor-services-app publishing messages to the `sdr.objects.created` topic when a resource is persisted. Then RabbitMQ routes this message to a queue `h2.druid_assigned`.  The `AssignPidJob` running via Sneakers works on messages from this queue.  Similarly workflow-server-rails publishes messages to the `sdr.workflow` topic when accessioning is completed.  RabbitMQ then routes these messages to a queue `h2.deposit_complete` which is processed by the `DepositStatusJob` via Sneakers.

There is also a `sdr.objects.embargo_lifted` topic that gets messages when dor-services-app lifts an embargo. H2 monitors those messages and logs an event when it detects one for an item it knows about.

## Branch aliasing

If your Git muscle memory is too strong and you find you keep typing `master` when you mean `main` (the default branch for H2), you can help yourself a bit by creating an alias thusly:

```shell
$ git symbolic-ref refs/heads/master refs/heads/main
```
