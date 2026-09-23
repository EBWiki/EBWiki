# frozen_string_literal: true

require 'administrate/base_dashboard'

class PhotoCandidateDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    case: Field::BelongsTo,
    subject_name: Field::String,
    source: Field::Select.with_options(
      searchable: false,
      collection: lambda { |field|
        field.resource.class.send(field.attribute.to_s.pluralize).keys
      }
    ),
    title: Field::String,
    image_url: Field::String,
    page_url: Field::String,
    license: Field::String,
    license_url: Field::String,
    author: Field::String,
    score: Field::Number,
    status: Field::Select.with_options(
      searchable: false,
      collection: lambda { |field|
        field.resource.class.send(field.attribute.to_s.pluralize).keys
      }
    ),
    likely_mugshot: Field::Boolean,
    notes: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    case
    subject_name
    status
    likely_mugshot
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    case
    subject_name
    source
    title
    image_url
    page_url
    license
    license_url
    author
    score
    status
    likely_mugshot
    notes
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    case
    subject_name
    source
    title
    image_url
    page_url
    license
    license_url
    author
    score
    status
    likely_mugshot
    notes
  ].freeze

  COLLECTION_FILTERS = {
    pending: ->(resources) { resources.pending },
    friendly: ->(resources) { resources.friendly.pending }
  }.freeze
end
