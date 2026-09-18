# Make the failing Harbor addition spec pass

EBWiki is at `/usr/src/ebwiki`. A spec at `spec/harbor/addition_spec.rb` is red because `HarborAddition.add` is wrong.

Fix the implementation so this command is green:

```bash
bundle exec rspec spec/harbor/addition_spec.rb
```

Do not delete or skip the spec. Use seed data only — no production dumps.
