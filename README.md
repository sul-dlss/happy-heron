[![CircleCI](https://circleci.com/gh/sul-dlss/happy-heron.svg?style=svg)](https://circleci.com/gh/sul-dlss/happy-heron)
[![Maintainability](https://api.codeclimate.com/v1/badges/3dbc6311e79b7045bed4/maintainability)](https://codeclimate.com/github/sul-dlss/happy-heron/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/3dbc6311e79b7045bed4/test_coverage)](https://codeclimate.com/github/sul-dlss/happy-heron/test_coverage)

# Self-Deposit for the Stanford Digital Repository (SDR)

happy-heron, or H2 (from "Hydrus 2.0"), is a Rails web application enabling users to deposit scholarly content into the SDR. It replaced [Hydrus](https://github.com/sul-dlss/hydrus).

**********************************
__H2 is currently frozen in production__

* The `production` branch is what is currently deployed in production.
* Any neccessary production patches should be applied to this branch and deployed with `cap prod deploy`.
* `main` cannot be deployed to production due to changes in `config/deploy/prod.rb`. This should be removed once the freeze is lifted.
* `sdr-deploy` has been configured to skip deploying H2 to production. This should be removed once the freeze is lifted.

**********************************

## UX Design

* Comps: https://projects.invisionapp.com/share/EQXC9CLKCR2
* Design Documentation: https://docs.google.com/document/d/1fcr2DYo7OrX-qTdeUOTWKSS1rlq_47sehESmbvgUsrk/edit

## Install Dependencies

Ruby dependencies can be installed with `bundle install`, JavaScript dependencies are installed via `yarn install`.

NOTE: H2 uses Ruby 3.0.3.

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

You can change user or roles by setting environment variables.  Note that you may need to clear your browser
session cookies to pick up the new roles set here, as they may be cached from a previous session.

```shell
REMOTE_USER=auser@stanford.edu ROLES=dlss:hydrus-app-administrators bin/dev
```

See https://github.com/sul-dlss/happy-heron/wiki/Complete-deposits-locally for some other useful info for local development.

### Globus Client Gem

The Globus client gem needs to be configured for it work in stage/qa during development.  You will need the client id/secrets/config from vault, and then add it to your `config/settings.local.yml`, matching the Globus config setup shown in `config/settings.yml`.

To get the config values from vault, see the [Globus client README](https://github.com/sul-dlss/globus_client/blob/main/README.md).

## Testing

To enable interactive debugging, invoke `bin/dev` as follows:

```
REMOTE_DEBUGGER=byebug bin/dev
```

And then start up the debugger in another window (only byebug is supported at this time):

```
bundle exec byebug -R localhost:8989
```

Note that, by default, the debugger will run on `localhost` on port `8989`. To change these values, add the `DEBUGGER_HOST` and `DEBUGGER_PORT` environment variables when invoking `bin/dev` above and make sure to poing `byebug -R` at those same values when starting up the debugger.

Start up dependencies with `docker compose up db` (with `-d` to run in background)

Create and migrate the database with `bundle exec rake db:prepare` and seed the test database with `RAILS_ENV=test bin/rails db:seed`

Then run tests with `bundle exec rspec`. If you also want to do style checks & linting, run Rubocop and RSpec serially via `bin/rake`.

### Faking Globus Client Calls

If you want to test the automated globus workflow setup on your laptop without actually making globus calls, add the following config
to the globus section of your `settings.local.yml` file:

```
globus:
  test_mode: true # for testing purposes in non-production only, simulates globus API calls
  test_user_exists: true # if test_mode=true, simulates if the globus user exists
```

Setting `test_mode` to true will prevent the GlobusClient from making actual API calls and will simply assume they succeed.
To simulate if a user is currently known to globus or not, set the `test_user_exists` to true or false depending on what you want
to test.  You can change from false to true after creating an object and refreshing the page to simulate the user completing the
globus account setup.  When `test_mode` is set to true, a message is shown in the top navigation to note you are in test mode.

### Integration

Spin up all docker compose services for local development and in-browser testing:

```shell
$ docker compose up # use -d to run in background
```

This will spin up the H2 web application, its background workers, and all service dependencies declared in docker-compose.yml.

### Cypress
Cypress is primarily used to test features implemented with JS/Stimulus. Cypress tests are located in `cypress/spec`.

To run cypress UI:
```shell
bin/cypress open
```

TO run cypress tests headlessly:
```shell
bin/cypress run
```

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
WORKERS=AssignPidJob,DepositCompleteJob,RecordEmbargoReleaseJob bin/rake sneakers:run
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

H2 relies upon dor-services-app publishing messages to the `sdr.objects.created` topic when a resource is persisted. Then RabbitMQ routes this message to a queue `h2.druid_assigned`.  The `AssignPidJob` running via Sneakers works on messages from this queue.  Similarly workflow-server-rails publishes messages to the `sdr.workflow` topic when accessioning is completed.  RabbitMQ then routes these messages to a queue `h2.deposit_complete` which is processed by the `DepositCompleteJob` via Sneakers.

There is also a `sdr.objects.embargo_lifted` topic that gets messages when dor-services-app lifts an embargo. H2 monitors those messages and logs an event when it detects one for an item it knows about.
