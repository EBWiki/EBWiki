# frozen_string_literal: true

require 'administrate/base_dashboard'

class AgencyDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    case_agencies: Field::HasMany,
    cases: Field::HasMany,
    city: Field::String,
    email: Field::String,
    jurisdiction: Field::Select.with_options(searchable: false, collection: lambda { |field|
      field.resource.class.send(field.attribute.to_s.pluralize).keys
    }),
    latitude: Field::Number.with_options(decimals: 2),
    longitude: Field::Number.with_options(decimals: 2),
    name: Field::String,
    slug: Field::String,
    state: Field::BelongsTo,
    street_address: Field::String,
    telephone: Field::String,
    versions: Field::HasMany,
    website: Field::String,
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
    case_agencies
    cases
    city
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    case_agencies
    cases
    city
    email
    jurisdiction
    latitude
    longitude
    name
    slug
    state
    street_address
    telephone
    versions
    website
    zipcode
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    case_agencies
    cases
    city
    email
    jurisdiction
    latitude
    longitude
    name
    slug
    state
    street_address
    telephone
    versions
    website
    zipcode
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

  # Overwrite this method to customize how agencies are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(agency)
  #   "Agency ##{agency.id}"
  # end
end
