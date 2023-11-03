[![CircleCI](https://circleci.com/gh/sul-dlss/happy-heron.svg?style=svg)](https://circleci.com/gh/sul-dlss/happy-heron)
[![Maintainability](https://api.codeclimate.com/v1/badges/3dbc6311e79b7045bed4/maintainability)](https://codeclimate.com/github/sul-dlss/happy-heron/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/3dbc6311e79b7045bed4/test_coverage)](https://codeclimate.com/github/sul-dlss/happy-heron/test_coverage)

# Self-Deposit for the Stanford Digital Repository (SDR)

happy-heron, or H2 (from "Hydrus 2.0"), is a Rails web application enabling users to deposit scholarly content into the SDR. It replaced [Hydrus](https://github.com/sul-dlss/hydrus).

## UX Design

* Comps: https://projects.invisionapp.com/share/EQXC9CLKCR2
* Design Documentation: https://docs.google.com/document/d/1fcr2DYo7OrX-qTdeUOTWKSS1rlq_47sehESmbvgUsrk/edit

## Install Dependencies

Ruby dependencies can be installed with `bundle install`, JavaScript dependencies are installed via `yarn install`.

NOTE: H2 uses Ruby 3.2.2

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
session cookies to pick up the new roles set here, as they may be cached from a previous session.  If you want to
avoid clearing _all_ your cookies, e.g. to prevent logging out of various services, you may be able to clear cookies
for specific top-level domains (e.g. stanford.edu) by using your browser's settings (e.g. 
`Privacy and Security > Cookies and Site Data > Manage Data` in Firefox).  You may be able to clear specific cookies
for specific subdomains (e.g. sdr.stanford.edu) by visiting a page at that subdomain, and using the storage inspector
tool in dev tools (e.g. `Web Developer Tools > Storage > Cookies` in Firefox).

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

Then run tests with `bundle exec rspec`. (**NOTE**: This does not run accessibility tests, which are slow. To run these, use `bundle exec rspec --tag accessibility`.)

If you also want to do style checks & linting of Ruby code and ERBs, run `bin/rake`.

To run just the linters, run `bin/rake lint`. To run the linters individually, run `bundle exec erblint --lint-all` and `bundle exec rubocop`

### Faking Globus Client Calls

If you want to test the automated globus workflow setup on your laptop without actually making globus calls, add the following config
to the globus section of your `settings.local.yml` file:

```
globus:
  test_mode: true # for testing purposes in non-production only, simulates globus API calls
  test_user_valid: true # if test_mode=true, simulates if the globus user exists
```

Setting `test_mode` to true will prevent the GlobusClient from making actual API calls and will simply assume they succeed.
To simulate if a user is currently valid in globus or not, set the `test_user_valid` to true or false depending on what you want
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

## Cron check-ins

Some cron jobs (configured via the whenever gem) are integrated with Honeybadger check-ins. These cron jobs will check-in with HB (via a curl request to an HB endpoint) whenever run. If a cron job does not check-in as expected, HB will alert.

Cron check-ins are configured in the following locations:
1. `config/schedule.rb`: This specifies which cron jobs check-in and what setting keys to use for the checkin key. See this file for more details.
2. `config/settings.yml`: Stubs out a check-in key for each cron job. Since we may not want to have a check-in for all environments, this stub key will be used and produce a null check-in.
3. `config/settings/production.yml` in shared_configs: This contains the actual check-in keys.
4. HB notification page: Check-ins are configured per project in HB. To configure a check-in, the cron schedule will be needed, which can be found with `bundle exec whenever`. After a check-in is created, the check-in key will be available. (If the URL is `https://api.honeybadger.io/v1/check_in/rkIdpB` then the check-in key will be `rkIdpB`).

## Architecture

H2 uses the [SDR API](https://github.com/sul-dlss/sdr-api) to deposit collections and works (both files and metadata) into SDR.

H2 relies upon dor-services-app publishing messages to the `sdr.objects.created` topic when a resource is persisted. Then RabbitMQ routes this message to a queue `h2.druid_assigned`.  The `AssignPidJob` running via Sneakers works on messages from this queue.  Similarly workflow-server-rails publishes messages to the `sdr.workflow` topic when accessioning is completed.  RabbitMQ then routes these messages to a queue `h2.deposit_complete` which is processed by the `DepositCompleteJob` via Sneakers.

There is also a `sdr.objects.embargo_lifted` topic that gets messages when dor-services-app lifts an embargo. H2 monitors those messages and logs an event when it detects one for an item it knows about.

## Reset Process (for QA/Stage)

### Requirements

* Hydrus APO
   * QA: druid:zx485kb6348
   * Stage: druid:zw306xn5593

### Steps

1. [Reset the database](https://github.com/sul-dlss/DeveloperPlaybook/blob/main/best-practices/db_reset.md) including seeding.
2. Clear the file upload directory: `rm -fr /data/h2-files/*`

Bogus change for setting up ZenHub pipeling for Review/QA
