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

Start up dependencies with `docker-compose up db redis` (with `-d` to run in background).

To run the H2 application in development mode, set `REMOTE_USER` because we aren't running behind Shibboleth, and set the `ROLES` environment variable to grant your fake user session administrative privileges:

```shell
REMOTE_USER=auser@stanford.edu ROLES=dlss:hydrus-app-administrators bin/rails server
```

If you are going to be changing any of the assets compiled by webpack (e.g., JavaScript code, stylesheets), you may also find it helpful to run the webpack dev server which speeds up page reloads after asset changes:

```shell
bin/webpack-dev-server
```

## Testing

Start up dependencies with `docker-compose up db` (with `-d` to run in background), then run tests with `bundle exec rspec`. If you also want to do style checks & linting, run Rubocop and RSpec serially via `bin/rake`.

### Integration

Spin up all docker-compose services for local development and in-browser testing:

```shell
$ docker-compose up # use -d to run in background
```

This will spin up the H2 web application, its background workers, and all service dependencies declared in docker-compose.yml.

## Type checking

H2 uses Sorbet optional Ruby type checking. Run a manual static type check via `srb tc`; note that CI for H2 will automate this.

After adding a new gem to the Gemfile, or running `bundle update`, build the new type definitions with `srb rbi update`. Or, if you prefer, you can automate that step (see following section).

### Automation (OPTIONAL)

If you would like to automate this step, consider using a git pre-push hook.

**Note**: this can occasionally take 2-3 minutes to complete, depending on how much has changed between HEAD and what you're pushing, so do this at your own discretion.

To do this, create a file named `.git/hooks/pre-push` and add code like the following:

```bash
#!/usr/bin/env bash

# Abort push if any commands error out
set -e

# Check if any local changes since last commit
function pending_changes_to {
    git diff --name-only --diff-filter=ACM | grep --quiet "^$1"
}

# Check if any local changes committed
function committed_changes_to {
    git diff --name-only main | grep --quiet "^$1"
}

if committed_changes_to 'Gemfile.lock'
then
    echo '*** Regenerating Sorbet RBIs for gem dependencies (as this branch has changed Gemfile.lock)'
    echo
    env SRB_YES=1 bundle exec srb rbi gems
fi

if committed_changes_to 'app/'
then
   echo '*** Regenerating Sorbet RBIs for application (as this branch has changed files in app/)'
   echo
   bundle exec rake rails_rbi:all
   bundle exec srb rbi suggest-typed
fi

# Run typechecks and linter before pushing (feel free to comment out)
echo '*** Running sorbet typecheck'
echo
bundle exec srb tc
echo '*** Running rubocop ruby linter'
echo
bundle exec rubocop

# Squash sorbet changes into last commit if there are any
if pending_changes_to 'sorbet/'
then
    echo '*** Squashing sorbet type definition changes into last commit'
    git add sorbet
    git commit --amend --no-edit
fi
```

and then make the hook executable via `chmod +x .git/hooks/pre-push`

Thereafter, every time you push commits that change `Gemfile.lock` or any files in `app`, Sorbet will update type-checking information as appropriate.

#### Note: Requires Postgres

Before running `rake rails_rbi:all`, make sure the `db` docker-compose service is running, else the type definitions for the app's models will be deleted.

#### Note: Updating hidden definitions

Occasionally, particularly if `srb tc` results in an error such as [7003](https://sorbet.org/docs/error-reference#7003) or [4010](https://sorbet.org/docs/error-reference#4010), you may need to update hidden definitions. This can happen, for instance, [when changing a file from `# typed: ignore` to another sigil](https://sorbet.org/docs/static#upgrading-a-file-from-ignore-to-any-other-sigil). When this happened, update hidden definitions via `bundle exec srb rbi hidden-definitions`. Note that this operation can take a few minutes to complete. [Read more about the hidden definition RBI](https://sorbet.org/docs/rbi#the-hidden-definition-rbi).

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
WORKERS=AssignPidJob,DepositStatusJob bin/rake sneakers:run
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

## Migration

The first step is to migrate all the [Hydrus Collections](https://argo.stanford.edu/catalog?f%5Bexploded_tag_ssim%5D%5B%5D=Project+%3A+Hydrus&f%5BobjectType_ssim%5D%5B%5D=collection)

We do this by exporting from the Hydrus server (see https://github.com/sul-dlss/hydrus/pull/507)

```
RAILS_ENV=production bin/export-collections > collections.jsonl
RAILS_ENV=production bin/export-items > items.jsonl
```

Then download these files to the h2 server you want to load the collections on and run:

```
RAILS_ENV=production bin/migrate-collections collections.jsonl
```

Next mount the `/data/hydrus-files` mount on the server you are importing to.

Next import the items with their files:
```
RAILS_ENV=production bin/migrate-items items.jsonl
```

And finally run the script to batch update the types for some items:
```
RAILS_ENV=production bin/batch-update-types migration_item_type_updates.csv
```

## Branch aliasing

If your Git muscle memory is too strong and you find you keep typing `master` when you mean `main` (the default branch for H2), you can help yourself a bit by creating an alias thusly:

```shell
$ git symbolic-ref refs/heads/master refs/heads/main
```
