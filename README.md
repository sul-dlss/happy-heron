# H2 Self-deposit front end for the Stanford Digital Repository

## Install Dependencies
Ruby dependencies can be installed with `bundle install`, Javascript dependencies are installed via `yarn install`.

## Testing

Start up dependencies with `docker-compose up`, then run tests with `bundle exec rspec`.

## Type checking

Sorbet is used for optional type checking.  Do a static type check via `srb tc`.  After adding a new gem to the Gemfile, build the new type definitions with `srb rbi update`. Then commit the changes in `sorbet/` to git.

## Architecture

At the end of the 2020 workcycle, H2 should use the sdr-api to do file and metadata deposits. 
