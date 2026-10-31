# frozen_string_literal: true

# Idempotent demo cases for the login-gated Railway staging site only.
module StagingSampleContent
  SAMPLES = [
    {
      slug: 'staging-sample-columbus-oh',
      title: 'Staging sample: Columbus',
      city: 'Columbus',
      state_code: 'OH',
      latitude: 39.9612,
      longitude: -82.9988,
      subject_name: 'Alex Rivera',
      subject_age: 34
    },
    {
      slug: 'staging-sample-atlanta-ga',
      title: 'Staging sample: Atlanta',
      city: 'Atlanta',
      state_code: 'GA',
      latitude: 33.7490,
      longitude: -84.3880,
      subject_name: 'Jordan Lee',
      subject_age: 28
    },
    {
      slug: 'staging-sample-oakland-ca',
      title: 'Staging sample: Oakland',
      city: 'Oakland',
      state_code: 'CA',
      latitude: 37.8044,
      longitude: -122.2712,
      subject_name: 'Sam Okonkwo',
      subject_age: 41
    }
  ].freeze

  STAGING_CASE_COPY = {
    date: Date.new(2020, 6, 1),
    overview: 'Staging-only sample case for brand and map review. Not production data.',
    summary: 'Staging sample content.',
    blurb: 'Demonstration record for the Railway staging site.'
  }.freeze

  module_function

  def ensure!(logger: Rails.logger)
    return unless Rails.env.staging?

    SAMPLES.each do |attrs|
      ensure_case!(attrs, logger: logger)
    end
    Rails.cache.delete('case_locations')
    logger.info("[StagingSampleContent] ensured #{SAMPLES.size} sample cases")
  end

  def ensure_case!(attrs, logger:)
    state = find_or_create_state!(attrs[:state_code])
    kase = Case.find_or_initialize_by(slug: attrs[:slug])
    return if kase.persisted?

    kase.assign_attributes(sample_case_attributes(attrs, state))
    kase.save!
    kase.subjects.find_or_create_by!(name: attrs[:subject_name], age: attrs[:subject_age])
    logger.info("[StagingSampleContent] created #{attrs[:slug]}")
  end

  def find_or_create_state!(state_code)
    State.find_or_create_by!(ansi_code: state_code) do |row|
      row.name = state_code
      row.iso = "US-#{state_code}"
    end
  end

  def sample_case_attributes(attrs, state)
    attrs.slice(:title, :city, :latitude, :longitude).merge(state: state, **STAGING_CASE_COPY)
  end
  private_class_method :ensure_case!, :find_or_create_state!, :sample_case_attributes
end
