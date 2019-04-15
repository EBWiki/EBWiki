# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Case do
  describe 'validity' do
    it { should validate_presence_of(:city).with_message('Please add a city.') }
    it { should validate_presence_of(:subjects).with_message('at least one subject is required') }

    it_behaves_like 'a sanatized_record'

    it do
      should validate_presence_of(:overview)
        .with_message('An overview of the case is required')
    end

    it do
      should validate_presence_of(:summary).with_message('Please use the last field at the bottom of this form ' \
             'to summarize your edits to the case.')
    end

    it do
      should validate_presence_of(:state_id)
        .with_message('Please specify the state where this incident occurred before saving.')
    end

    it 'should not accept dates in the future' do
      this_case = build(:case, date: 10.days.from_now)
      expect(this_case).to be_invalid
      expect(this_case.errors.to_a).to include('Date must be in the past')
    end
  end

  describe 'blurb' do
    it { should validate_presence_of(:blurb).with_message('A blurb about the case is required.') }
    it { should validate_length_of(:blurb).is_at_most(500) }
  end
end

describe 'versioning', versioning: true do
  it 'starts versioning when a new this_case is created' do
    this_case = FactoryBot.create(:case)
    expect(this_case.versions.size).to eq 2
    expect(this_case.versions.map(&:event)).to eq %w[create update]
    expect(this_case.versions[0].event).to eq 'create'
  end

  it 'adds a version when the title is changed' do
    this_case = FactoryBot.create(:case)
    this_case.update_attribute(:title, 'A New Title')
    expect(this_case.versions.size).to eq 3
    expect(this_case.versions.map(&:event)).to eq %w[create update update]
  end

  it 'adds a version when the overview is changed' do
    this_case = FactoryBot.create(:case)
    this_case.update_attribute(:overview, 'An Old Case')
    expect(this_case.versions.size).to eq 3
    expect(this_case.versions.map(&:event)).to eq %w[create update update]
  end

  it 'adds a version when the date is changed' do
    this_case = FactoryBot.create(:case)
    this_case.update_attribute(:date, (Time.current - 1.day))
    expect(this_case.versions.size).to eq 3
    expect(this_case.versions.map(&:event)).to eq %w[create update update]
  end

  it 'adds a version when the city is changed' do
    this_case = FactoryBot.create(:case)
    this_case.update_attribute(:city, 'Buffalo')
    expect(this_case.versions.size).to eq 3
    expect(this_case.versions.map(&:event)).to eq %w[create update update]
  end

  it 'adds a version when the avatar is changed' do
    this_case = FactoryBot.create(:case)
    this_case.update_attribute(:avatar, 'new_avatar')
    expect(this_case.versions.size).to eq 3
    expect(this_case.versions.map(&:event)).to eq %w[create update update]
  end

  it 'adds a version when the video url is changed' do
    this_case = FactoryBot.create(:case)
    this_case.update_attribute(:video_url, 'new_video.com')
    expect(this_case.versions.size).to eq 3
    expect(this_case.versions.map(&:event)).to eq %w[create update update]
  end

  it 'adds a version when the slug is changed' do
    this_case = FactoryBot.create(:case)
    this_case.update_attribute(:slug, 'joel-osteen')
    expect(this_case.versions.size).to eq 3
    expect(this_case.versions.map(&:event)).to eq %w[create update update]
  end

  it 'does not add a version when the attribute is the same' do
    this_case = FactoryBot.create(:case, title: 'The Title')
    this_case.update_attribute(:title, 'The Title')
    expect(this_case.versions.size).to eq 2
  end

  it 'copies the this_case.summary attribute to version.comment' do
    this_case = FactoryBot.create(:case, title: 'The Title')
    this_case.update_attributes(title: 'The Title has changed', summary: 'fixed the title')
    expect(this_case.versions.last.comment).to eq 'fixed the title'
  end
end

describe 'slugs' do
  it 'adds city to slug to maintain uniqueness' do
    this_case = FactoryBot.create(:case, title: 'The Title')
    this_case2 = FactoryBot.create(:case, title: 'The Title')
    expect(this_case2.slug).to eq 'the-title-albany'
    expect(this_case.slug).not_to eq this_case2.slug
  end

  it 'updates slug if this_case title is updated' do
    this_case = FactoryBot.create(:case, title: 'The Title')
    this_case.slug = nil
    this_case.title = 'Another Title'
    this_case.save!
    this_case.reload
    expect(this_case.slug).to eq 'another-title'
  end
end

describe '#new', versioning: true do
  it 'takes three parameters and returns an Case object' do
    this_case = build(:case)
    expect(this_case).to be_an_instance_of Case
  end
end

describe '#title', versioning: true do
  it 'returns the correct title' do
    this_case = build(:case)
    expect(this_case.title).to include 'Title'
  end
end

describe 'follower_count', versioning: true do
  it 'gives the correct followers count' do
    this_case = FactoryBot.create(:case, id: 10)
    FactoryBot.create(:follow, followable_id: 10)
    expect(this_case.followers.count).to eq(1)
  end

  it 'has a zero counter cache to start' do
    FactoryBot.create(:case)
    expect(Case.last.follows_count).to eq(0)
  end

  it 'has a counter cache' do
    this_case = FactoryBot.create(:case)
    expect do
      this_case.follows.create(
        follower_id: 1,
        followable_id: this_case.id,
        followable_type: 'Case',
        follower_type: 'User'
      )
    end.to change { this_case.reload.follows_count }.by(1)
  end
end

describe '#content', versioning: true do
  it 'returns the correct content' do
    this_case = build(:case)
    expect(this_case.overview).to eq 'A new case'
  end
end

describe 'geocoded', versioning: true do
  it 'generates longitude and latitude from city and state on save' do
    this_case = FactoryBot.create(:case)
    expect(this_case.latitude).to be_a(Float)
    expect(this_case.longitude).to be_a(Float)
  end

  it 'updates geocoded coordinates when relevant fields are updated' do
    this_case = FactoryBot.create(:case)
    ohio = FactoryBot.create(:state_ohio)

    expect do
      this_case.update_attributes(city: 'Worthington',
                                  state_id: ohio.id,
                                  address: '1867 Irving Road',
                                  zipcode: '43085')
    end.to(change { this_case.latitude })
  end
end

describe '#nearby_cases', versioning: true do
  it 'returns an empty array if no cases are nearby' do
    this_case = FactoryBot.create(:case)
    expect(this_case.nearby_cases).to be_empty
  end

  it 'does not raise an error if the nearbys method returns nil' do
    this_case = FactoryBot.create(:case)
    allow(this_case).to receive(:nearbys).and_return(nil)
    expect { this_case.nearby_cases }.not_to raise_error
  end
end

describe '#default_avatar_url', versioning: true do
  it 'takes the avatar''s default URL and turns this into a column' do
    this_case = FactoryBot.create(:case)
    avatar_mock = double('Avatar', url: 'https://avatar.com')
    allow(this_case).to receive(:default_avatar_url).and_return(avatar_mock.url)
    expect(this_case.default_avatar_url).to_not be_nil
  end
end
describe 'scopes', versioning: true do
  it 'returns cases based on case' do
    louisiana = FactoryBot.create(:state_louisiana)
    texas = FactoryBot.create(:state_texas)

    FactoryBot.create(:case,
                      city: 'Houston',
                      state_id: texas.id)
    louisiana_case = FactoryBot.create(:case,
                                       city: 'Baton Rouge',
                                       state_id: louisiana.id)

    sorted_cases = Case.by_state texas.id
    expect(sorted_cases.count).to eq 1
    expect(sorted_cases.to_a).not_to include louisiana_case
  end

  it 'returns the most recently occurring cases' do
    dc = FactoryBot.create(:state_dc)
    louisiana = FactoryBot.create(:state_louisiana)
    texas = FactoryBot.create(:state_texas)

    FactoryBot.create(
      :case,
      city: 'Houston',
      state_id: texas.id,
      date: Time.current
    )
    FactoryBot.create(:case,
                      city: 'Baton Rouge',
                      state_id: louisiana.id,
                      date: 2.weeks.ago)
    dc_case = FactoryBot.create(:case,
                                city: 'Washington',
                                state_id: dc.id,
                                date: 1.year.ago)

    recent_cases = Case.most_recent_occurrences 1.month.ago
    expect(recent_cases.count).to eq 2
    expect(recent_cases.to_a).not_to include(dc_case)
  end

  it 'returns the most recently updated cases' do
    dc = FactoryBot.create(:state_dc)
    louisiana = FactoryBot.create(:state_louisiana)
    texas = FactoryBot.create(:state_texas)

    FactoryBot.create(:case,
                      city: 'Houston',
                      state_id: texas.id,
                      updated_at: Time.current)
    FactoryBot.create(:case,
                      city: 'Baton Rouge',
                      state_id: louisiana.id,
                      updated_at: 2.weeks.ago)
    dc_case = FactoryBot.create(:case,
                                city: 'Washington',
                                state_id: dc.id,
                                updated_at: 1.year.ago)
    recent_cases = Case.recently_updated 1.month.ago
    expect(recent_cases.count).to eq 3
    expect(recent_cases.to_a).to include(dc_case)
  end

  it 'returns cases sorted by update date' do
    dc = FactoryBot.create(:state_dc)
    louisiana = FactoryBot.create(:state_louisiana)
    texas = FactoryBot.create(:state_texas)

    FactoryBot.create(:case,
                      city: 'Houston',
                      state_id: texas.id,
                      updated_at: Time.current)
    FactoryBot.create(:case,
                      city: 'Baton Rouge',
                      state_id: louisiana.id,
                      updated_at: 2.weeks.ago)
    dc_case = FactoryBot.create(:case,
                                city: 'Washington',
                                state_id: dc.id,
                                updated_at: 1.year.ago)

    sorted_cases = Case.sorted_by_update 2
    expect(sorted_cases.count).to eq 2
    expect(sorted_cases.to_a).to include(dc_case)
  end

  it 'returns cases sorted by number of followers' do
    dc = FactoryBot.create(:state_dc)
    louisiana = FactoryBot.create(:state_louisiana)
    texas = FactoryBot.create(:state_texas)

    texas_case = FactoryBot.create(:case,
                                   city: 'Houston',
                                   state_id: texas.id,
                                   updated_at: Time.current)
    louisiana_case = FactoryBot.create(:case,
                                       city: 'Baton Rouge',
                                       state_id: louisiana.id,
                                       updated_at: 2.weeks.ago)
    dc_case = FactoryBot.create(:case,
                                city: 'Washington',
                                state_id: dc.id,
                                updated_at: 1.year.ago)

    FactoryBot.create(:follow, followable_id: texas_case.id)
    FactoryBot.create(:follow, followable_id: texas_case.id)
    FactoryBot.create(:follow, followable_id: dc_case.id)
    FactoryBot.create(:follow, followable_id: dc_case.id)
    FactoryBot.create(:follow, followable_id: louisiana_case.id)

    sorted_cases = Case.sorted_by_followers 2
    expect(sorted_cases.count).to eq 2
    expect(sorted_cases.to_a).not_to include(louisiana_case)
  end
end
