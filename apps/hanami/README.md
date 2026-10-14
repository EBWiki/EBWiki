# Hanami photo search preview (GKT-1338)

Small Rack app shaped for the future Hanami staging service (`hanami.ebwiki.org`). It demonstrates the `/photos` grid, text search, and cosine “find similar” using **synthetic demo cases and placeholder SVG tiles only**.

## Run locally

```bash
cd apps/hanami
bundle install
ruby script/generate_demo_data.rb   # if demo_cases.json or placeholders are missing
bundle exec puma -p 9393 config.ru
```

Open http://127.0.0.1:9393/photos

## Railway (optional)

Build and run with the included `Dockerfile` as a separate service in the EBWiki staging project. No GPU required. Set `PORT` from Railway.

This PR does not wire a public hostname; use local screenshots or deploy the service manually.
