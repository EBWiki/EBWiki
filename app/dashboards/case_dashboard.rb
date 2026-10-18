# frozen_string_literal: true

require 'administrate/base_dashboard'

class CaseDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    address: Field::String,
    age: Field::Number,
    agencies: Field::HasMany,
    blurb: Field::Text,
    case_agencies: Field::HasMany,
    cause_of_death: Field::Select.with_options(searchable: false, collection: lambda { |field|
      field.resource.class.send(field.attribute.to_s.pluralize).keys
    }),
    city: Field::String,
    comments: Field::HasMany,
    community_action: Field::Text,
    country: Field::String,
    date: Field::Date,
    follows: Field::HasMany,
    follows_count: Field::Number,
    latitude: Field::Number.with_options(decimals: 2),
    links: Field::HasMany,
    litigation: Field::Text,
    longitude: Field::Number.with_options(decimals: 2),
    overview: Field::Text,
    slug: Field::String,
    state: Field::BelongsTo,
    subjects: Field::HasMany,
    summary: Field::Text,
    title: Field::String,
    versions: Field::HasMany,
    video_url: Field::String,
    zipcode: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    title
    city
    state
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    title
    city
    state
    address
    zipcode
    country
    date
    age
    cause_of_death
    overview
    blurb
    community_action
    litigation
    video_url
    agencies
    subjects
    comments
    links
    follows
    follows_count
    slug
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    title
    city
    state
    address
    zipcode
    country
    date
    age
    cause_of_death
    overview
    blurb
    community_action
    litigation
    video_url
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how cases are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(case)
  #   "Case ##{case.id}"
  # end
end
