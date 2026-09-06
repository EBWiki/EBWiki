# frozen_string_literal: true

module FriendlyPhotos
  # Idempotent fixtures used by Playwright against the Rails test server.
  class E2eSeed
    include Service

    EMAIL = 'e2e@example.com'
    PASSWORD = 'e2e-password'
    SLUGS = %w[e2e-missing-photo e2e-mugshot-case e2e-portrait-case].freeze
    SUBSTANTIAL_CASE_THRESHOLD = 100
    FRIENDLY_CANDIDATE = {
      subject_name: 'Jordan Doe', source: 'wikimedia_commons',
      title: 'Jordan Doe portrait', license: 'CC BY-SA 4.0', author: 'Family',
      image_url: 'https://upload.wikimedia.org/wikipedia/commons/a/ab/e2e-seed-portrait.jpg',
      page_url: 'https://commons.wikimedia.org/wiki/File:Jordan_Doe_portrait.jpg',
      score: 3, likely_mugshot: false
    }.freeze
    MUGSHOT_CANDIDATE = {
      subject_name: 'Jordan Doe', source: 'wikimedia_commons',
      title: 'Jordan Doe mugshot', license: 'Public domain', author: 'Sheriff',
      image_url: 'https://upload.wikimedia.org/wikipedia/commons/b/bc/e2e-seed-mugshot.jpg',
      page_url: 'https://commons.wikimedia.org/wiki/File:Jordan_Doe_mugshot.jpg',
      score: -5, likely_mugshot: true, notes: 'mugshot'
    }.freeze

    def call
      reset_records
      state = find_or_create_state
      cases = build_cases(state)
      attach_subjects(cases)
      create_candidates(cases[:missing])
      cases.each_value(&:reload)
      cases.merge(user: upsert_user)
    end

    private

    def reset_records
      if substantial_existing_data?
        clear_seed_associations
      else
        with_pg_pooler_retry { delete_seed_records }
      end
    end

    def substantial_existing_data?
      Case.count > SUBSTANTIAL_CASE_THRESHOLD
    end

    def delete_seed_records
      seed_case_ids = Case.where(slug: SLUGS).pluck(:id)
      return if seed_case_ids.empty?

      PhotoCandidate.where(case_id: seed_case_ids).delete_all
      Subject.where(case_id: seed_case_ids).delete_all
      Case.where(id: seed_case_ids).delete_all
      User.where(email: EMAIL).delete_all
    end

    def clear_seed_associations
      seed_case_ids = Case.where(slug: SLUGS).pluck(:id)
      return if seed_case_ids.empty?

      with_pg_pooler_retry do
        PhotoCandidate.where(case_id: seed_case_ids).delete_all
        Subject.where(case_id: seed_case_ids).delete_all
      end
    end

    def with_pg_pooler_retry
      yield
    rescue ActiveRecord::StatementInvalid => e
      raise unless cached_plan_error?(e)

      reconnect_active_record!
      yield
    end

    def cached_plan_error?(error)
      cause = error.cause
      if cause.is_a?(PG::FeatureNotSupported) && cause.message.include?('cached plan')
        return true
      end
      return true if error.is_a?(ActiveRecord::PreparedStatementCacheExpired)

      error.message.include?('cached plan must not change result type')
    end

    def reconnect_active_record!
      ReviewDbConnection.reset_pool!
    end

    def find_or_create_state
      State.find_or_create_by!(ansi_code: 'NY') do |state|
        state.name = 'New York'
        state.iso = 'US-NY'
      end
    end

    def upsert_user
      user = User.find_by(email: EMAIL)
      if user
        user.update!(
          password: PASSWORD,
          password_confirmation: PASSWORD,
          confirmed_at: Time.current
        )
        user
      else
        create_user
      end
    end

    def create_user
      User.create!(
        name: 'E2E Editor',
        email: EMAIL,
        password: PASSWORD,
        password_confirmation: PASSWORD,
        confirmed_at: Time.current
      )
    end

    def build_cases(state)
      missing = upsert_case(state, 'E2E Missing Photo', 'e2e-missing-photo', 'unclassified')
      mugshot = upsert_case(state, 'E2E Mugshot Case', 'e2e-mugshot-case', 'mugshot')
      portrait = upsert_case(state, 'E2E Portrait Case', 'e2e-portrait-case', 'portrait')
      attach_filename(mugshot, 'uploads/case/avatar/1/booking_photo.jpg')
      attach_filename(portrait, 'uploads/case/avatar/2/family_portrait.jpg')
      { missing: missing, mugshot: mugshot, portrait: portrait }
    end

    def upsert_case(state, title, slug, avatar_kind)
      this_case = Case.find_or_initialize_by(slug: slug)
      this_case.assign_attributes(case_attrs(state, title, slug, avatar_kind))
      this_case.save!
      this_case
    end

    def case_attrs(state, title, slug, avatar_kind)
      {
        title: title, slug: slug, overview: 'E2E overview', city: 'Albany',
        date: Date.current, state: state, summary: 'e2e seed',
        blurb: 'E2E blurb about the case', avatar_kind: avatar_kind
      }
    end

    def attach_filename(this_case, filename)
      this_case.update_columns(avatar: filename) # rubocop:disable Rails/SkipsModelValidations
    end

    def attach_subjects(cases)
      create_subject(cases[:missing], 'Jordan Doe')
      create_subject(cases[:mugshot], 'Riley Mugshot')
      create_subject(cases[:portrait], 'Casey Portrait')
    end

    def create_subject(this_case, name)
      Subject.create!(name: name, case: this_case)
    end

    def create_candidates(this_case)
      create_candidate(this_case, FRIENDLY_CANDIDATE)
      create_candidate(this_case, MUGSHOT_CANDIDATE)
    end

    def create_candidate(this_case, attrs)
      this_case.photo_candidates.create!(attrs)
    end
  end
end
