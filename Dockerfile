FROM ruby:2.7.8

# Install Node.js
RUN apt-get update -qq && apt-get install -y nodejs npm postgresql-client && npm install -g yarn

WORKDIR /usr/src/ebwiki

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

COPY . .

EXPOSE 3000
ENTRYPOINT ["./dev_provisions/entrypoint.sh"]
