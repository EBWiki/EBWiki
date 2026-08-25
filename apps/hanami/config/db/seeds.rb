# frozen_string_literal: true

# Idempotent demo rows for an empty throwaway database (CI, local LOAD_SCHEMA=1,
# Railway staging). Never point this at the Rails production database.

require "bcrypt"
require "date"

users = Hanami.app["relations.users"]

unless users.where(email: "admin@example.com").exist?
  now = Time.now.utc
  password = ENV.fetch("STAGING_SEED_PASSWORD", "password123")
  encrypted_password = BCrypt::Password.create(password)

  state_id = Hanami.app["relations.states"].insert(
    name: "South Carolina",
    ansi_code: "SC",
    slug: "south-carolina",
    created_at: now,
    updated_at: now
  )

  [
    {email: "admin@example.com", name: "Staging Admin", admin: true, analyst: false, slug: "staging-admin"},
    {email: "analyst@example.com", name: "Staging Analyst", admin: false, analyst: true, slug: "staging-analyst"},
    {email: "editor@example.com", name: "Staging Editor", admin: false, analyst: false, slug: "staging-editor"}
  ].each do |attrs|
    users.insert(
      email: attrs[:email],
      encrypted_password: encrypted_password,
      name: attrs[:name],
      admin: attrs[:admin],
      analyst: attrs[:analyst],
      slug: attrs[:slug],
      confirmed_at: now,
      created_at: now,
      updated_at: now,
      sign_in_count: 0
    )
  end

  case_id = Hanami.app["relations.cases"].insert(
    title: "Walter Scott",
    slug: "walter-scott",
    city: "North Charleston",
    date: Date.new(2015, 4, 4),
    state_id: state_id,
    overview: "<p>Walter Scott was shot in the back while fleeing. This is seed data for Hanami staging.</p>",
    blurb: "Walter Scott was shot by a North Charleston police officer.",
    summary: "Staging seed case",
    cause_of_death: "shooting",
    created_at: now,
    updated_at: now
  )

  Hanami.app["relations.subjects"].insert(
    case_id: case_id,
    name: "Walter Scott",
    age: 50,
    created_at: now,
    updated_at: now
  )

  agency_id = Hanami.app["relations.agencies"].insert(
    name: "North Charleston Police Department",
    slug: "ncpd",
    city: "North Charleston",
    state_id: state_id,
    created_at: now,
    updated_at: now
  )

  Hanami.app["relations.case_agencies"].insert(
    case_id: case_id,
    agency_id: agency_id,
    created_at: now,
    updated_at: now
  )

  Hanami.app["relations.organizations"].insert(
    name: "Color of Change",
    website: "https://colorofchange.org",
    description: "Staging seed organization",
    created_at: now,
    updated_at: now
  )
end
