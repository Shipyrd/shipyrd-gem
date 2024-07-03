# Shipyrd

This is a simple helper gem to connect your Kamal hooks(pre-build, pre-build, pre-deploy, post-deploy) to Shipyrd.

[Shipyrd](https://shipyrd.io) is a deployment dashboard built for Kamal.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add shipyrd

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install shipyrd

## Usage

Please see the main Shipyrd app([https://github.com/shipyrd/shipyrd](https://github.com/shipyrd/shipyrd)) for setup and usage instructions.

## Usage with Docker

You can run a dockerized version of `shipyrd-gem` by adding the following function to your `~/.bashrc` or similar:

```bash
shipyrd() {
  docker run --rm -v "${PWD}:/workdir" --env-file <(env | grep -E '^(KAMAL_|SHIPYRD_)') ghcr.io/shipyrd/shipyrd-gem /shipyrd/bin/"$@"
}
```

Then within a specific Kamal hook (e.g. `pre-connect`), you can call `shipyrd` like this:

```bash
#!/usr/bin/env bash

shipyrd pre-connect
```

## Recording a deploy

This gem currently sends the following deploy details to record a deploy. The various `KAMAL_` ENV variables are set via Kamal when the [hooks are called](https://kamal-deploy.org/docs/hooks/hooks-overview/).

* `ENV["KAMAL_COMMAND"]`,
* `ENV["KAMAL_DESTINATION"]`,
* `ENV["KAMAL_HOSTS"`,
* `ENV["KAMAL_PERFORMER"]` - `gh config get -h github.com username` is preferred if set.
* `ENV["KAMAL_RECORDED_AT"]`,
* `ENV["KAMAL_ROLE"]`,
* `ENV["KAMAL_RUNTIME"]`,
* `ENV["KAMAL_SERVICE_VERSION"]`,
* `ENV["KAMAL_SUBCOMMAND"]`,
* `ENV["KAMAL_VERSION"]`,
* `ENV["SHIPYRD_API_KEY"]`,
* `ENV["SHIPYRD_HOST"]`,
* Commit message - The first 90 characters of your commit message `git show -s --format=%s`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shipyrd/shipyrd-gem. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[shipyrd/shipyrd-gem/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Shipyrd project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shipyrd/shipyrd-gem/blob/main/CODE_OF_CONDUCT.md).
