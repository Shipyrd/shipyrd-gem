# Use the official Ruby 3.3.0 Alpine image as the base image
FROM ruby:3.3.0-alpine

# Set the working directory to /shipyrd
WORKDIR /shipyrd

# Copy the Gemfile, shipyrd.gemspec into the container
COPY Gemfile shipyrd.gemspec ./

# Required in shipyrd.gemspec
COPY lib/shipyrd/version.rb /shipyrd/lib/shipyrd/version.rb

# Install system dependencies
RUN apk add --no-cache --update build-base git \
    && gem install bundler --version=2.5.14 \
    && bundle install

# Copy the rest of our application code into the container.
# We do this after bundle install, to avoid having to run bundle
# every time we do small fixes in the source code.
COPY . .

# Install the gem locally from the project folder
RUN gem build shipyrd.gemspec && \
    gem install ./shipyrd-*.gem --no-document

# Set the working directory to /workdir
WORKDIR /workdir

# Tell git it's safe to access /workdir/.git even if
# the directory is owned by a different user
RUN git config --global --add safe.directory /workdir
