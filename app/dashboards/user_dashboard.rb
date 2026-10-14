# frozen_string_literal: true

require 'administrate/base_dashboard'

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    admin: Field::Boolean,
    analyst: Field::Boolean,
    city: Field::String,
    comments: Field::HasMany,
    confirmed_at: Field::DateTime,
    current_sign_in_at: Field::DateTime,
    description: Field::Text,
    email: Field::String,
    facebook_url: Field::String,
    follows: Field::HasMany,
    last_sign_in_at: Field::DateTime,
    latitude: Field::Number.with_options(decimals: 2),
    linkedin: Field::String,
    longitude: Field::Number.with_options(decimals: 2),
    name: Field::String,
    sign_in_count: Field::Number,
    slug: Field::String,
    state: Field::String,
    state_id: Field::Number,
    subscribed: Field::Boolean,
    twitter_url: Field::String,
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
    name
    email
    admin
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    email
    admin
    analyst
    city
    state
    description
    facebook_url
    twitter_url
    linkedin
    comments
    follows
    sign_in_count
    current_sign_in_at
    last_sign_in_at
    confirmed_at
    subscribed
    slug
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    name
    email
    admin
    analyst
    city
    state
    description
    facebook_url
    twitter_url
    linkedin
    subscribed
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

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(user)
  #   "User ##{user.id}"
  # end
end
