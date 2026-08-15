# frozen_string_literal: true

module FriendlyPhotos
  # Idempotent fixtures used by Playwright against the Rails test server.
  class E2eSeed
    include Service

    EMAIL = 'e2e@example.com'
    PASSWORD = 'e2e-password'
    SLUGS = %w[e2e-missing-photo e2e-mugshot-case e2e-portrait-case].freeze

    def call
      reset_records
      state = find_or_create_state
      cases = build_cases(state)
      attach_subjects(cases)
      create_candidates(cases[:missing])
      cases.merge(user: create_user)
    end

    private

    def reset_records
      Case.where(slug: SLUGS).find_each(&:destroy)
      User.find_by(email: EMAIL)&.destroy
    end

    def find_or_create_state
      State.find_or_create_by!(ansi_code: 'NY') do |state|
        state.name = 'New York'
        state.iso = 'US-NY'
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
      missing = create_case(state, 'E2E Missing Photo', 'e2e-missing-photo', 'unclassified')
      mugshot = create_case(state, 'E2E Mugshot Case', 'e2e-mugshot-case', 'mugshot')
      portrait = create_case(state, 'E2E Portrait Case', 'e2e-portrait-case', 'portrait')
      attach_filename(mugshot, 'uploads/case/avatar/1/booking_photo.jpg')
      attach_filename(portrait, 'uploads/case/avatar/2/family_portrait.jpg')
      { missing: missing, mugshot: mugshot, portrait: portrait }
    end

    def create_case(state, title, slug, avatar_kind)
      Case.create!(case_attrs(state, title, slug, avatar_kind))
    end

    def case_attrs(state, title, slug, avatar_kind)
      {
        title: title, slug: slug, overview: 'E2E overview', city: 'Albany',
        date: Date.current, state: state, summary: 'e2e seed',
        blurb: 'E2E blurb about the case', avatar_kind: avatar_kind,
        latitude: 42.6525793, longitude: -73.7562317
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
      create_candidate(this_case, friendly_candidate_attrs)
      create_candidate(this_case, mugshot_candidate_attrs)
    end

    def create_candidate(this_case, attrs)
      this_case.photo_candidates.create!(attrs)
    end

    def friendly_candidate_attrs
      {
        subject_name: 'Jordan Doe',
        source: 'wikimedia_commons',
        title: 'Jordan Doe portrait',
        image_url: 'https://upload.wikimedia.org/wikipedia/commons/a/ab/e2e-seed-portrait.jpg',
        page_url: 'https://commons.wikimedia.org/wiki/File:Jordan_Doe_portrait.jpg',
        license: 'CC BY-SA 4.0',
        author: 'Family',
        score: 3,
        likely_mugshot: false
      }
    end

    def mugshot_candidate_attrs
      {
        subject_name: 'Jordan Doe',
        source: 'wikimedia_commons',
        title: 'Jordan Doe mugshot',
        image_url: 'https://upload.wikimedia.org/wikipedia/commons/b/bc/e2e-seed-mugshot.jpg',
        page_url: 'https://commons.wikimedia.org/wiki/File:Jordan_Doe_mugshot.jpg',
        license: 'Public domain',
        author: 'Sheriff',
        score: -5,
        likely_mugshot: true,
        notes: 'mugshot'
      }
    end
  end
end
