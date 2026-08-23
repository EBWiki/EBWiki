# frozen_string_literal: true

require "yaml"

RSpec.describe EbWiki::Repos::CaseRepo, :db do
  subject(:repo) { described_class.new }

  it "finds a case page by slug with subjects, agencies, and links" do
    state_id = TestData.insert_state
    case_id = TestData.insert_case(state_id: state_id)
    TestData.insert_subject(case_id: case_id, name: "Walter Scott", age: 50)
    agency_id = TestData.insert_agency
    TestData.insert_case_agency(case_id: case_id, agency_id: agency_id)
    TestData.insert_link(case_id: case_id)

    page = repo.find_page("walter-scott")

    expect(page[:record].title).to eq("Walter Scott")
    expect(page[:state].ansi_code).to eq("SC")
    expect(page[:subjects].map(&:name)).to eq(["Walter Scott"])
    expect(page[:agencies].map(&:name)).to include("North Charleston Police Department")
    expect(page[:links].map(&:url)).to include("https://ebwiki.org/cases/walter-scott")
  end

  it "returns nil when the slug is missing" do
    expect(repo.find_page("missing")).to be_nil
  end

  it "restores case columns from a YAML version snapshot" do
    state_id = TestData.insert_state
    case_id = TestData.insert_case(state_id: state_id, city: "Charleston")
    version_id = TestData.insert_version(
      case_id: case_id,
      object: YAML.dump("city" => "North Charleston", "title" => "Walter Scott")
    )
    user = Struct.new(:id).new(1)

    record = repo.revert_to_version("walter-scott", version_id, user: user)

    expect(record.city).to eq("North Charleston")
    expect(repo.revert_to_version("walter-scott", version_id, user: user)).not_to eq(:no_snapshot)
  end

  it "orders the homepage by incident date, newest first" do
    state_id = TestData.insert_state
    TestData.insert_case(state_id: state_id, title: "Older", slug: "older", date: Date.new(2014, 1, 1))
    TestData.insert_case(state_id: state_id, title: "Newer", slug: "newer", date: Date.new(2016, 1, 1))

    titles = repo.homepage.map(&:title)

    expect(titles.first).to eq("Newer")
    expect(titles.last).to eq("Older")
  end
end
