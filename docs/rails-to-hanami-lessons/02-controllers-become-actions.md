# Lesson 02 — Controllers become actions

**Runtime:** 10 minutes  
**Pair with:** `app/controllers/cases_controller.rb` and `apps/hanami/app/actions/cases/show.rb`

## Rails

A Rails controller is a bag of methods on one class. `CasesController#show`
loads a FriendlyId record, then the view asks the model for associations.

```ruby
# Rails shape
def show
  @this_case = Case.friendly.find(params[:id])
end
```

Callbacks, `before_action :authenticate_user!`, and helper modules accumulate
on that same class.

## Hanami

Hanami gives each endpoint its own action class. The action loads data and
hands a hash to a view object. The template only sees exposures.

```ruby
# apps/hanami/app/actions/cases/show.rb
slug = request.params[:id]
page = case_repo.find_page(slug)
halt 404 unless page
response.render(view, case_page: page, viewer: viewer, following: following)
```

The view (`app/views/cases/show.rb`) exposes `this_case`, `subjects`,
`agencies`. The ERB looks familiar on purpose.

## Teaching point

Do not port `ApplicationController`. Port one URL. Then another. EBWiki's
`EbWiki::Action` only adds session lookup and `require_user!`. That is the
whole shared layer.

## Video beats

1. `curl /cases/walter-scott` on both apps.
2. Diff the HTML. Same slug. Same city. Different object graph.
3. Open `config/routes.rb` in both trees. Hanami still says `resources :cases`.

## Exercise

Port `MapsController#index` to `Actions::Maps::Index`. You already can: it is
on this branch. Trace the request from route → action → view → Leaflet JSON.
