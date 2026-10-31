# frozen_string_literal: true

require 'administrate/base_dashboard'

class CasePhotoCandidateDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    case: Field::BelongsTo,
    image_url: Field::String,
    source_page_url: Field::String,
    source_name: Field::String,
    license_label: Field::String,
    license_url: Field::String,
    title: Field::String,
    description: Field::Text,
    status: Field::Select.with_options(
      searchable: false,
      collection: ->(field) { field.resource.class.statuses.keys }
    ),
    reviewed_at: Field::DateTime,
    reviewed_by: Field::BelongsTo,
    rejection_reason: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    case
    source_name
    status
    license_label
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    case
    image_url
    source_page_url
    source_name
    license_label
    license_url
    title
    description
    status
    reviewed_by
    reviewed_at
    rejection_reason
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = [].freeze

  COLLECTION_FILTERS = {
    pending: ->(resources) { resources.pending }
  }.freeze

  def display_resource(candidate)
    "Photo candidate ##{candidate.id} (#{candidate.case.title})"
  end
end
