# Use Ruby 3.1.4 as base image
FROM ruby:3.1.4-slim

# Set environment variables
ENV RAILS_ENV=development
ENV BUNDLE_PATH=/usr/local/bundle
ENV BUNDLE_WITHOUT=""

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/src/ebwiki

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle config --global frozen 1 && \
    bundle install --without test production

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p tmp/pids log

# Expose port
EXPOSE 3000

# Default command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
