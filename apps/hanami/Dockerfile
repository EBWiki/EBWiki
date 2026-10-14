FROM ruby:3.4.2-slim

WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .

ENV PORT=9393
EXPOSE 9393

CMD ["sh", "-c", "bundle exec puma -b tcp://0.0.0.0:${PORT} config.ru"]
