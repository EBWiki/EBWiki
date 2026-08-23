# frozen_string_literal: true

require "bcrypt"

module TestData
  module_function

  def now
    Time.now.utc
  end

  def insert_state(name: "South Carolina", ansi_code: "SC", slug: "south-carolina")
    relations[:states].insert(
      name: name,
      ansi_code: ansi_code,
      slug: slug,
      created_at: now,
      updated_at: now
    )
  end

  def insert_case(state_id:, title: "Walter Scott", slug: "walter-scott", city: "North Charleston",
                  date: Date.new(2015, 4, 4), cause_of_death: "shooting",
                  overview: "<p>Walter Scott was shot in the back while fleeing.</p>",
                  blurb: "Walter Scott was shot by a North Charleston police officer.",
                  summary: "Initial case entry",
                  updated_at: nil)
    relations[:cases].insert(
      title: title,
      slug: slug,
      city: city,
      date: date,
      state_id: state_id,
      overview: overview,
      blurb: blurb,
      summary: summary,
      cause_of_death: cause_of_death,
      created_at: now,
      updated_at: updated_at || now
    )
  end

  def insert_subject(case_id:, name: "Walter Scott", age: 50)
    relations[:subjects].insert(
      case_id: case_id,
      name: name,
      age: age,
      created_at: now,
      updated_at: now
    )
  end

  def insert_agency(name: "North Charleston Police Department", slug: "ncpd")
    relations[:agencies].insert(
      name: name,
      slug: slug,
      created_at: now,
      updated_at: now
    )
  end

  def insert_case_agency(case_id:, agency_id:)
    relations[:case_agencies].insert(
      case_id: case_id,
      agency_id: agency_id,
      created_at: now,
      updated_at: now
    )
  end

  def insert_version(case_id:, event: "update", comment: "Corrected city spelling", whodunnit: "1")
    relations[:versions].insert(
      item_type: "Case",
      item_id: case_id,
      event: event,
      comment: comment,
      whodunnit: whodunnit,
      created_at: now
    )
  end

  def insert_user(email: "editor@example.com", password: "password123", name: "Editor", admin: false)
    relations[:users].insert(
      email: email,
      encrypted_password: BCrypt::Password.create(password),
      name: name,
      admin: admin,
      analyst: false,
      confirmed_at: now,
      created_at: now,
      updated_at: now,
      sign_in_count: 0
    )
  end

  def insert_organization(name: "Color of Change", website: "https://colorofchange.org")
    relations[:organizations].insert(
      name: name,
      website: website,
      created_at: now,
      updated_at: now
    )
  end

  def insert_link(case_id:, url: "https://ebwiki.org/cases/walter-scott")
    relations[:links].insert(
      url: url,
      linkable_id: case_id,
      linkable_type: "Case",
      created_at: now,
      updated_at: now
    )
  end

  def relations
    {
      states: Hanami.app["relations.states"],
      cases: Hanami.app["relations.cases"],
      subjects: Hanami.app["relations.subjects"],
      agencies: Hanami.app["relations.agencies"],
      case_agencies: Hanami.app["relations.case_agencies"],
      links: Hanami.app["relations.links"],
      versions: Hanami.app["relations.versions"],
      users: Hanami.app["relations.users"],
      comments: Hanami.app["relations.comments"],
      follows: Hanami.app["relations.follows"],
      organizations: Hanami.app["relations.organizations"]
    }
  end
end
