# Lesson 03 — Keep the table, lose the model

**Runtime:** 15 minutes  
**Pair with:** `app/models/case.rb` and `apps/hanami/app/repos/case_repo.rb`

## Rails

`Case` is a fat model: enums, nested attributes, PaperTrail, FriendlyId,
CarrierWave, geocoder, `pg_search`, followable. One class owns reads, writes,
and callbacks.

## Hanami

ROM splits that:

| Piece | File | Job |
| --- | --- | --- |
| Relation | `app/relations/cases.rb` | Schema + associations |
| Repo | `app/repos/case_repo.rb` | Queries and writes |
| Action | `app/actions/cases/create.rb` | HTTP boundary |
| View | `app/views/cases/show.rb` | What the template may see |

`CaseRepo#find_page` does the work Rails hid in `friendly.find` plus
`has_many :subjects` plus polymorphic links:

```ruby
record = find_by_slug(slug)
{
  record: record,
  subjects: subjects.where(case_id: record.id).to_a,
  agencies: agencies_for(record.id),
  links: links.where(linkable_type: "Case", linkable_id: record.id).to_a
}
```

There is no `accepts_nested_attributes_for`. Create/update is an explicit
transaction in the repo.

## Teaching point

The hard part is not SQL. The hard part is deciding which Rails callbacks were
product rules (geocode before save, write a version row) and which were gem
ceremony.

## Video beats

1. Open `schema.rb` / `structure.sql`. Same `cases` table.
2. Count methods on `Case`. Count methods on `CaseRepo`.
3. Show `REVERTABLE_COLUMNS` and a YAML `versions.object` restore.

## Exercise

Write `CaseRepo#map_locations` without loading full case graphs. Compare it to
`MapsHelper#location_data` in Rails.
