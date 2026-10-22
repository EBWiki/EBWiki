# frozen_string_literal: true

# Builds a paginated memorial photo grid from URL filter parameters.
class MemorialPhotoGridQuery
  PER_PAGE = 24

  def initialize(filters:, logger: Rails.logger)
    @filters = filters
    @logger = logger
  end

  def call
    paginated = build_relation.page(filters.page).per(PER_PAGE)
    log_success(paginated)
    paginated
  rescue StandardError => e
    log_failure(e)
    ErrorReporter.report(e, memorial_photo_grid: filters.to_query_hash)
    raise MemorialPhotos::QueryError, e.message
  end

  private

  attr_reader :filters, :logger

  def build_relation
    relation = Case.memorial_photo_indexable.includes(:state, :agencies)
    relation = apply_structured_filters(relation)
    relation = apply_name_search(relation)
    apply_text_search(relation).order(date: :desc, title: :asc)
  end

  def log_success(paginated)
    logger.info(
      event: 'memorial_photo_grid.query',
      filters: filters.to_query_hash,
      result_count: paginated.total_count
    )
  end

  def log_failure(error)
    logger.error(
      event: 'memorial_photo_grid.query_failed',
      filters: filters.to_query_hash,
      error_class: error.class.name,
      error_message: error.message
    )
  end

  def apply_structured_filters(relation)
    relation = filter_by_state(relation)
    relation = filter_by_city(relation)
    relation = filter_by_year_range(relation)
    filter_by_agency(relation)
  end

  def filter_by_state(relation)
    return relation if filters.state_id.blank?

    relation.where(state_id: filters.state_id)
  end

  def filter_by_city(relation)
    return relation if filters.city.blank?

    escaped = ActiveRecord::Base.sanitize_sql_like(filters.city)
    relation.where('cases.city ILIKE ?', "%#{escaped}%")
  end

  def filter_by_year_range(relation)
    relation = apply_year_from(relation)
    apply_year_to(relation)
  end

  def apply_year_from(relation)
    return relation unless filters.year_from

    relation.where('EXTRACT(YEAR FROM cases.date) >= ?', filters.year_from)
  end

  def apply_year_to(relation)
    return relation unless filters.year_to

    relation.where('EXTRACT(YEAR FROM cases.date) <= ?', filters.year_to)
  end

  def filter_by_agency(relation)
    return relation if filters.agency_id.blank?

    case_ids = CaseAgency.where(agency_id: filters.agency_id).select(:case_id)
    relation.where(id: case_ids)
  end

  def apply_name_search(relation)
    return relation if filters.name.blank?

    relation.memorial_name_trgm(filters.name)
  end

  def apply_text_search(relation)
    return relation if filters.query.blank?

    relation.memorial_text_search(filters.query)
  end
end
